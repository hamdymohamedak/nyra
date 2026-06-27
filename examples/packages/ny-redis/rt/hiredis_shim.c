#include <hiredis/hiredis.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static char *nyra_redis_strdup(const char *s) {
    if (!s) {
        return NULL;
    }
    size_t n = strlen(s);
    char *out = (char *)malloc(n + 1);
    if (out) {
        memcpy(out, s, n + 1);
    }
    return out;
}

void *redis_connect(const char *host, int port) {
    if (!host || port <= 0) {
        return NULL;
    }
    struct timeval tv = {2, 0};
    redisContext *ctx = redisConnectWithTimeout(host, (int)port, tv);
    if (!ctx || ctx->err) {
        if (ctx) {
            redisFree(ctx);
        }
        return NULL;
    }
    return ctx;
}

int redis_ping(void *conn) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx) {
        return -1;
    }
    redisReply *reply = redisCommand(ctx, "PING");
    if (!reply) {
        return -1;
    }
    int ok = (reply->type == REDIS_REPLY_STATUS && reply->str && strcmp(reply->str, "PONG") == 0) ? 0 : -1;
    freeReplyObject(reply);
    return ok;
}

char *redis_get(void *conn, const char *key) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx || !key) {
        return nyra_redis_strdup("");
    }
    redisReply *reply = redisCommand(ctx, "GET %s", key);
    if (!reply) {
        return nyra_redis_strdup("");
    }
    char *out = nyra_redis_strdup("");
    if (reply->type == REDIS_REPLY_STRING && reply->str) {
        free(out);
        out = nyra_redis_strdup(reply->str);
    }
    freeReplyObject(reply);
    return out ? out : nyra_redis_strdup("");
}

int redis_set(void *conn, const char *key, const char *value, int ttl_sec) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx || !key || !value) {
        return -1;
    }
    redisReply *reply = NULL;
    if (ttl_sec > 0) {
        reply = redisCommand(ctx, "SET %s %s EX %d", key, value, ttl_sec);
    } else {
        reply = redisCommand(ctx, "SET %s %s", key, value);
    }
    if (!reply) {
        return -1;
    }
    int ok = (reply->type == REDIS_REPLY_STATUS && reply->str && strcmp(reply->str, "OK") == 0) ? 0 : -1;
    freeReplyObject(reply);
    return ok;
}

int redis_del(void *conn, const char *key) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx || !key) {
        return -1;
    }
    redisReply *reply = redisCommand(ctx, "DEL %s", key);
    if (!reply) {
        return -1;
    }
    int ok = (reply->type == REDIS_REPLY_INTEGER) ? 0 : -1;
    freeReplyObject(reply);
    return ok;
}

int redis_lpush(void *conn, const char *key, const char *value) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx || !key || !value) {
        return -1;
    }
    redisReply *reply = redisCommand(ctx, "LPUSH %s %s", key, value);
    if (!reply) {
        return -1;
    }
    int ok = (reply->type == REDIS_REPLY_INTEGER) ? (int)reply->integer : -1;
    freeReplyObject(reply);
    return ok;
}

char *redis_brpop(void *conn, const char *key, int timeout_sec) {
    redisContext *ctx = (redisContext *)conn;
    if (!ctx || !key) {
        return nyra_redis_strdup("");
    }
    if (timeout_sec < 0) {
        timeout_sec = 0;
    }
    redisReply *reply = redisCommand(ctx, "BRPOP %s %d", key, timeout_sec);
    if (!reply) {
        return nyra_redis_strdup("");
    }
    char *out = nyra_redis_strdup("");
    if (reply->type == REDIS_REPLY_ARRAY && reply->elements >= 2 && reply->element[1]->str) {
        free(out);
        out = nyra_redis_strdup(reply->element[1]->str);
    }
    freeReplyObject(reply);
    return out ? out : nyra_redis_strdup("");
}

void redis_close(void *conn) {
    redisContext *ctx = (redisContext *)conn;
    if (ctx) {
        redisFree(ctx);
    }
}

void redis_free_string(char *s) {
    if (s) {
        free(s);
    }
}

int ptr_is_null(void *p) {
    return p == NULL ? 1 : 0;
}
