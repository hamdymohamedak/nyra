#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int rt_tcp_connect(const char *host, int port);
extern char *rt_tcp_read(int fd, int max_bytes);
extern int rt_tcp_write(int fd, const char *data);
extern void rt_tcp_close(int fd);

static void parse_url(const char *url, char *host, size_t hcap, int *port, char *path, size_t pcap) {
    const char *p = url;
    *port = 80;
    host[0] = '\0';
    path[0] = '/';
    path[1] = '\0';
    if (strncmp(p, "https://", 8) == 0) {
        p += 8;
        *port = 443;
    } else if (strncmp(p, "http://", 7) == 0) {
        p += 7;
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

char *http_get(const char *url) {
    char host[256];
    char path[512];
    int port = 80;
    parse_url(url, host, sizeof(host), &port, path, sizeof(path));
    int fd = rt_tcp_connect(host, port);
    if (fd < 0) {
        return NULL;
    }
    char req[768];
    snprintf(req, sizeof(req), "GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n", path, host);
    if (rt_tcp_write(fd, req) != 0) {
        rt_tcp_close(fd);
        return NULL;
    }
    char *raw = rt_tcp_read(fd, 65536);
    rt_tcp_close(fd);
    if (!raw) {
        return NULL;
    }
    char *body = strstr(raw, "\r\n\r\n");
    if (!body) {
        return raw;
    }
    body += 4;
    char *out = strdup(body);
    free(raw);
    return out;
}

int http_status(const char *response_header) {
    if (!response_header || strncmp(response_header, "HTTP/", 5) != 0) {
        return 0;
    }
    const char *sp = strchr(response_header, ' ');
    if (!sp) {
        return 0;
    }
    return atoi(sp + 1);
}
