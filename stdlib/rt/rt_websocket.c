#include <openssl/sha.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NYRA_TLS_HANDLE_BASE 0x100000

extern int rt_tcp_connect(const char *host, int port);
extern char *rt_tcp_read(int fd, int max_bytes);
extern int rt_tcp_write(int fd, const char *data);
extern int rt_tcp_write_bytes(int fd, const char *data, int len);
extern int rt_tcp_read_bytes(int fd, char *buf, int len);
extern void rt_tcp_close(int fd);
extern int rt_tcp_listen(const char *host, int port);
extern int rt_tcp_accept(int listener_fd);
extern int tls_available(void);
extern int rt_tls_connect(const char *host, int port);
extern char *rt_tls_read(int handle, int max_bytes);
extern int rt_tls_write(int fd, const char *data);
extern int rt_tls_write_bytes(int handle, const char *data, int len);
extern int rt_tls_read_bytes(int handle, char *buf, int len);
extern void rt_tls_close(int handle);
extern int rt_tls_listen(const char *cert_pem_path, const char *key_pem_path, const char *host, int port);
extern int rt_tls_accept(int listener_handle);

static int ws_is_tls(int handle) {
    return handle >= NYRA_TLS_HANDLE_BASE;
}

static int ws_write_bytes(int handle, const char *data, int len) {
    if (ws_is_tls(handle)) {
        return rt_tls_write_bytes(handle, data, len);
    }
    return rt_tcp_write_bytes(handle, data, len);
}

static int ws_read_bytes(int handle, char *buf, int len) {
    if (ws_is_tls(handle)) {
        return rt_tls_read_bytes(handle, buf, len);
    }
    return rt_tcp_read_bytes(handle, buf, len);
}

static void ws_io_close(int handle) {
    if (ws_is_tls(handle)) {
        rt_tls_close(handle);
    } else {
        rt_tcp_close(handle);
    }
}

static void parse_ws_url(const char *url, char *host, size_t hcap, int *port, char *path, size_t pcap, int *use_tls) {
    const char *p = url;
    *port = 80;
    *use_tls = 0;
    host[0] = '\0';
    snprintf(path, pcap, "/");
    if (strncmp(p, "wss://", 6) == 0) {
        p += 6;
        *port = 443;
        *use_tls = 1;
    } else if (strncmp(p, "ws://", 5) == 0) {
        p += 5;
    }
    const char *slash = strchr(p, '/');
    const char *colon = strchr(p, ':');
    if (colon && (!slash || colon < slash)) {
        size_t hlen = (size_t)(colon - p);
        if (hlen >= hcap) {
            hlen = hcap - 1;
        }
        memcpy(host, p, hlen);
        host[hlen] = '\0';
        *port = atoi(colon + 1);
        if (slash) {
            snprintf(path, pcap, "%s", slash);
        }
    } else if (slash) {
        size_t hlen = (size_t)(slash - p);
        if (hlen >= hcap) {
            hlen = hcap - 1;
        }
        memcpy(host, p, hlen);
        host[hlen] = '\0';
        snprintf(path, pcap, "%s", slash);
    } else {
        snprintf(host, hcap, "%s", p);
    }
}

static const char b64_table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static char *base64_encode(const uint8_t *data, size_t len) {
    size_t out_cap = 4 * ((len + 2) / 3) + 1;
    char *out = (char *)malloc(out_cap);
    if (!out) {
        return NULL;
    }
    size_t i = 0;
    size_t j = 0;
    while (i < len) {
        uint32_t octet_a = data[i++];
        uint32_t octet_b = i < len ? data[i++] : 0;
        uint32_t octet_c = i < len ? data[i++] : 0;
        uint32_t triple = (octet_a << 16) | (octet_b << 8) | octet_c;
        out[j++] = b64_table[(triple >> 18) & 63];
        out[j++] = b64_table[(triple >> 12) & 63];
        out[j++] = (i > len + 1) ? '=' : b64_table[(triple >> 6) & 63];
        out[j++] = (i > len) ? '=' : b64_table[triple & 63];
    }
    out[j] = '\0';
    return out;
}

static char *ws_accept_key(const char *client_key) {
    char combined[256];
    snprintf(combined, sizeof(combined), "%s258EAFA5-E914-47DA-95CA-C5AB0DC85B11", client_key);
    unsigned char hash[SHA_DIGEST_LENGTH];
    SHA1((unsigned char *)combined, strlen(combined), hash);
    return base64_encode(hash, SHA_DIGEST_LENGTH);
}

static int ws_validate_accept(const char *response, const char *client_key) {
    if (!response || !client_key) {
        return 0;
    }
    char *expected = ws_accept_key(client_key);
    if (!expected) {
        return 0;
    }
    char needle[160];
    snprintf(needle, sizeof(needle), "Sec-WebSocket-Accept: %s", expected);
    int ok = strstr(response, needle) != NULL;
    free(expected);
    return ok;
}

int ws_connect(const char *url) {
    char host[256];
    char path[512];
    int port = 80;
    int use_tls = 0;
    parse_ws_url(url, host, sizeof(host), &port, path, sizeof(path), &use_tls);
    int handle = -1;
    if (use_tls) {
        if (tls_available() == 0) {
            return -1;
        }
        handle = rt_tls_connect(host, port);
    } else {
        handle = rt_tcp_connect(host, port);
    }
    if (handle < 0) {
        return -1;
    }
    srand((unsigned)time(NULL));
    uint8_t rnd[16];
    for (int i = 0; i < 16; i++) {
        rnd[i] = (uint8_t)(rand() & 0xff);
    }
    char *client_key = base64_encode(rnd, 16);
    if (!client_key) {
        ws_io_close(handle);
        return -1;
    }
    char req[1024];
    snprintf(req, sizeof(req),
             "GET %s HTTP/1.1\r\nHost: %s:%d\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: "
             "%s\r\nSec-WebSocket-Version: 13\r\n\r\n",
             path, host, port, client_key);
    int wrc = ws_is_tls(handle) ? rt_tls_write(handle, req) : rt_tcp_write(handle, req);
    if (wrc != 0) {
        free(client_key);
        ws_io_close(handle);
        return -1;
    }
    char *resp = ws_is_tls(handle) ? rt_tls_read(handle, 4096) : rt_tcp_read(handle, 4096);
    if (!resp || strstr(resp, "101") == NULL || !ws_validate_accept(resp, client_key)) {
        free(client_key);
        free(resp);
        ws_io_close(handle);
        return -1;
    }
    free(client_key);
    free(resp);
    return handle;
}

static int ws_write_frame(int handle, const char *payload, size_t len) {
    uint8_t hdr[14];
    size_t hlen = 0;
    hdr[hlen++] = 0x81;
    uint8_t mask[4] = {0x12, 0x34, 0x56, 0x78};
    if (len < 126) {
        hdr[hlen++] = 0x80 | (uint8_t)len;
    } else if (len <= 65535) {
        hdr[hlen++] = 0x80 | 126;
        hdr[hlen++] = (uint8_t)((len >> 8) & 0xff);
        hdr[hlen++] = (uint8_t)(len & 0xff);
    } else {
        return -1;
    }
    memcpy(hdr + hlen, mask, 4);
    hlen += 4;
    size_t total = hlen + len;
    char *frame = (char *)malloc(total);
    if (!frame) {
        return -1;
    }
    memcpy(frame, hdr, hlen);
    for (size_t i = 0; i < len; i++) {
        frame[hlen + i] = (char)(payload[i] ^ mask[i % 4]);
    }
    int rc = ws_write_bytes(handle, frame, (int)total);
    free(frame);
    return rc;
}

int ws_send_text(int handle, const char *text) {
    if (handle < 0 || !text) {
        return -1;
    }
    return ws_write_frame(handle, text, strlen(text));
}

char *ws_recv_text(int fd, int max_bytes) {
    if (fd < 0) {
        return NULL;
    }
    if (max_bytes <= 0) {
        max_bytes = 65536;
    }
    char hbuf[2];
    if (ws_read_bytes(fd, hbuf, 2) != 0) {
        return NULL;
    }
    uint8_t b1 = (uint8_t)hbuf[1];
    uint64_t plen = b1 & 0x7f;
    int masked = b1 & 0x80;
    if (plen == 126) {
        char ext[2];
        if (ws_read_bytes(fd, ext, 2) != 0) {
            return NULL;
        }
        plen = ((uint64_t)(uint8_t)ext[0] << 8) | (uint8_t)ext[1];
    } else if (plen == 127) {
        return NULL;
    }
    if ((int)plen > max_bytes) {
        return NULL;
    }
    uint8_t mask[4] = {0, 0, 0, 0};
    if (masked) {
        char mbuf[4];
        if (ws_read_bytes(fd, mbuf, 4) != 0) {
            return NULL;
        }
        memcpy(mask, mbuf, 4);
    }
    char *payload = (char *)malloc((size_t)plen + 1);
    if (!payload) {
        return NULL;
    }
    if (ws_read_bytes(fd, payload, (int)plen) != 0) {
        free(payload);
        return NULL;
    }
    for (uint64_t i = 0; i < plen; i++) {
        payload[i] = (char)((uint8_t)payload[i] ^ (masked ? mask[i % 4] : 0));
    }
    payload[plen] = '\0';
    return payload;
}

void ws_close(int fd) {
    if (fd >= 0) {
        ws_io_close(fd);
    }
}

static char *ws_extract_header(const char *raw, const char *name) {
    if (!raw || !name) {
        return NULL;
    }
    char needle[128];
    snprintf(needle, sizeof(needle), "%s: ", name);
    const char *p = strstr(raw, needle);
    if (!p) {
        return NULL;
    }
    p += strlen(needle);
    const char *end = strstr(p, "\r\n");
    size_t n = end ? (size_t)(end - p) : strlen(p);
    char *out = (char *)malloc(n + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, p, n);
    out[n] = '\0';
    return out;
}

static int ws_write_frame_server(int handle, const char *payload, size_t len) {
    uint8_t hdr[10];
    size_t hlen = 0;
    hdr[hlen++] = 0x81;
    if (len < 126) {
        hdr[hlen++] = (uint8_t)len;
    } else if (len <= 65535) {
        hdr[hlen++] = 126;
        hdr[hlen++] = (uint8_t)((len >> 8) & 0xff);
        hdr[hlen++] = (uint8_t)(len & 0xff);
    } else {
        return -1;
    }
    size_t total = hlen + len;
    char *frame = (char *)malloc(total);
    if (!frame) {
        return -1;
    }
    memcpy(frame, hdr, hlen);
    memcpy(frame + hlen, payload, len);
    int rc = ws_write_bytes(handle, frame, (int)total);
    free(frame);
    return rc;
}

int ws_listen(const char *host, int port) {
    return rt_tcp_listen(host, port);
}

int ws_listen_tls(const char *cert_path, const char *key_path, const char *host, int port) {
    return rt_tls_listen(cert_path, key_path, host, port);
}

static int ws_accept_handshake_on(int handle, int use_tls) {
    if (handle < 0) {
        return -1;
    }
    char *req = use_tls ? rt_tls_read(handle, 8192) : rt_tcp_read(handle, 8192);
    if (!req || strstr(req, "Upgrade: websocket") == NULL) {
        free(req);
        ws_io_close(handle);
        return -1;
    }
    char *key = ws_extract_header(req, "Sec-WebSocket-Key");
    if (!key) {
        free(req);
        ws_io_close(handle);
        return -1;
    }
    char *accept = ws_accept_key(key);
    free(key);
    free(req);
    if (!accept) {
        ws_io_close(handle);
        return -1;
    }
    char resp[512];
    snprintf(resp, sizeof(resp),
             "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "
             "%s\r\n\r\n",
             accept);
    free(accept);
    int wrc = use_tls ? rt_tls_write(handle, resp) : rt_tcp_write(handle, resp);
    if (wrc != 0) {
        ws_io_close(handle);
        return -1;
    }
    return handle;
}

int ws_accept_handshake(int listener_fd) {
    if (listener_fd < 0) {
        return -1;
    }
    int client = rt_tcp_accept(listener_fd);
    if (client < 0) {
        return -1;
    }
    return ws_accept_handshake_on(client, 0);
}

int ws_accept_tls_handshake(int tls_listener_handle) {
    if (tls_listener_handle < 0) {
        return -1;
    }
    int client = rt_tls_accept(tls_listener_handle);
    if (client < 0) {
        return -1;
    }
    return ws_accept_handshake_on(client, 1);
}

int ws_send_text_server(int handle, const char *text) {
    if (handle < 0 || !text) {
        return -1;
    }
    return ws_write_frame_server(handle, text, strlen(text));
}
