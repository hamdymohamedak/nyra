#include <stdlib.h>
#include <string.h>

#if defined(__has_include)
#if __has_include(<openssl/ssl.h>)
#define NYRA_OPENSSL_EXTRA 1
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/x509.h>
#endif
#endif

#ifndef NYRA_OPENSSL_EXTRA
#define NYRA_OPENSSL_EXTRA 0
#endif

static char *dup_cstr(const char *s) {
    if (!s) {
        return NULL;
    }
    size_t n = strlen(s);
    char *out = (char *)malloc(n + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, s, n + 1);
    return out;
}

int rsa_available(void) {
    return NYRA_OPENSSL_EXTRA ? 1 : 0;
}

char *rsa_public_encrypt_pem(const char *pem_pub, const char *plaintext) {
#if !NYRA_OPENSSL_EXTRA
    (void)pem_pub;
    (void)plaintext;
    return NULL;
#else
    if (!pem_pub || !plaintext) {
        return NULL;
    }
    BIO *bio = BIO_new_mem_buf(pem_pub, (int)strlen(pem_pub));
    if (!bio) {
        return NULL;
    }
    EVP_PKEY *pkey = PEM_read_bio_PUBKEY(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!pkey) {
        return NULL;
    }
    EVP_PKEY_CTX *ctx = EVP_PKEY_CTX_new(pkey, NULL);
    if (!ctx) {
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_PKEY_encrypt_init(ctx) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_PADDING) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    size_t in_len = strlen(plaintext);
    size_t out_len = 0;
    if (EVP_PKEY_encrypt(ctx, NULL, &out_len, (const unsigned char *)plaintext, in_len) <= 0) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    unsigned char *out = (unsigned char *)malloc(out_len);
    if (!out) {
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_PKEY_encrypt(ctx, out, &out_len, (const unsigned char *)plaintext, in_len) <= 0) {
        free(out);
        EVP_PKEY_CTX_free(ctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    EVP_PKEY_CTX_free(ctx);
    EVP_PKEY_free(pkey);
    static const char hex[] = "0123456789abcdef";
    char *hex_out = (char *)malloc(out_len * 2 + 1);
    if (!hex_out) {
        free(out);
        return NULL;
    }
    for (size_t i = 0; i < out_len; i++) {
        hex_out[i * 2] = hex[out[i] >> 4];
        hex_out[i * 2 + 1] = hex[out[i] & 0x0f];
    }
    hex_out[out_len * 2] = '\0';
    free(out);
    return hex_out;
#endif
}

char *rsa_sha256_sign_pem(const char *pem_priv, const char *message) {
#if !NYRA_OPENSSL_EXTRA
    (void)pem_priv;
    (void)message;
    return NULL;
#else
    if (!pem_priv || !message) {
        return NULL;
    }
    BIO *bio = BIO_new_mem_buf(pem_priv, (int)strlen(pem_priv));
    if (!bio) {
        return NULL;
    }
    EVP_PKEY *pkey = PEM_read_bio_PrivateKey(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!pkey) {
        return NULL;
    }
    EVP_MD_CTX *mdctx = EVP_MD_CTX_new();
    if (!mdctx) {
        EVP_PKEY_free(pkey);
        return NULL;
    }
    size_t sig_len = 0;
    unsigned char *sig = NULL;
    if (EVP_DigestSignInit(mdctx, NULL, EVP_sha256(), NULL, pkey) <= 0) {
        EVP_MD_CTX_free(mdctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_DigestSignUpdate(mdctx, message, strlen(message)) <= 0) {
        EVP_MD_CTX_free(mdctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_DigestSignFinal(mdctx, NULL, &sig_len) <= 0) {
        EVP_MD_CTX_free(mdctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    sig = (unsigned char *)malloc(sig_len);
    if (!sig) {
        EVP_MD_CTX_free(mdctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    if (EVP_DigestSignFinal(mdctx, sig, &sig_len) <= 0) {
        free(sig);
        EVP_MD_CTX_free(mdctx);
        EVP_PKEY_free(pkey);
        return NULL;
    }
    EVP_MD_CTX_free(mdctx);
    EVP_PKEY_free(pkey);
    static const char hex[] = "0123456789abcdef";
    char *hex_out = (char *)malloc(sig_len * 2 + 1);
    if (!hex_out) {
        free(sig);
        return NULL;
    }
    for (size_t i = 0; i < sig_len; i++) {
        hex_out[i * 2] = hex[sig[i] >> 4];
        hex_out[i * 2 + 1] = hex[sig[i] & 0x0f];
    }
    hex_out[sig_len * 2] = '\0';
    free(sig);
    return hex_out;
#endif
}

int x509_available(void) {
    return NYRA_OPENSSL_EXTRA ? 1 : 0;
}

char *x509_pem_subject(const char *pem_cert) {
#if !NYRA_OPENSSL_EXTRA
    (void)pem_cert;
    return NULL;
#else
    if (!pem_cert) {
        return NULL;
    }
    BIO *bio = BIO_new_mem_buf(pem_cert, (int)strlen(pem_cert));
    if (!bio) {
        return NULL;
    }
    X509 *cert = PEM_read_bio_X509(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!cert) {
        return NULL;
    }
    X509_NAME *subj = X509_get_subject_name(cert);
    if (!subj) {
        X509_free(cert);
        return NULL;
    }
    char buf[512];
    buf[0] = '\0';
    X509_NAME_oneline(subj, buf, (int)sizeof(buf));
    X509_free(cert);
    return dup_cstr(buf);
#endif
}

char *x509_pem_issuer(const char *pem_cert) {
#if !NYRA_OPENSSL_EXTRA
    (void)pem_cert;
    return NULL;
#else
    if (!pem_cert) {
        return NULL;
    }
    BIO *bio = BIO_new_mem_buf(pem_cert, (int)strlen(pem_cert));
    if (!bio) {
        return NULL;
    }
    X509 *cert = PEM_read_bio_X509(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!cert) {
        return NULL;
    }
    X509_NAME *issuer = X509_get_issuer_name(cert);
    if (!issuer) {
        X509_free(cert);
        return NULL;
    }
    char buf[512];
    buf[0] = '\0';
    X509_NAME_oneline(issuer, buf, (int)sizeof(buf));
    X509_free(cert);
    return dup_cstr(buf);
#endif
}

int x509_pem_verify_time(const char *pem_cert) {
#if !NYRA_OPENSSL_EXTRA
    (void)pem_cert;
    return -1;
#else
    if (!pem_cert) {
        return -1;
    }
    BIO *bio = BIO_new_mem_buf(pem_cert, (int)strlen(pem_cert));
    if (!bio) {
        return -1;
    }
    X509 *cert = PEM_read_bio_X509(bio, NULL, NULL, NULL);
    BIO_free(bio);
    if (!cert) {
        return -1;
    }
    int ok = (X509_cmp_current_time(X509_get0_notBefore(cert)) <= 0 &&
              X509_cmp_current_time(X509_get0_notAfter(cert)) >= 0)
                 ? 0
                 : -1;
    X509_free(cert);
    return ok;
#endif
}
