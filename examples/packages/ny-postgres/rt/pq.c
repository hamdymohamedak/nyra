#include <libpq-fe.h>
#include <stdlib.h>
#include <string.h>

static char *nyra_pq_strdup(const char *s) {
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

void *pq_connect(const char *spec) {
    if (!spec) {
        return NULL;
    }
    PGconn *pg = PQconnectdb(spec);
    if (PQstatus(pg) != CONNECTION_OK) {
        PQfinish(pg);
        return NULL;
    }
    return pg;
}

int pq_exec(void *conn, const char *sql) {
    PGconn *pg = (PGconn *)conn;
    if (!pg || !sql) {
        return -1;
    }
    PGresult *res = PQexec(pg, sql);
    ExecStatusType st = PQresultStatus(res);
    PQclear(res);
    return (st == PGRES_COMMAND_OK || st == PGRES_TUPLES_OK) ? 0 : -1;
}

char *pq_query_scalar(void *conn, const char *sql) {
    PGconn *pg = (PGconn *)conn;
    if (!pg || !sql) {
        return nyra_pq_strdup("");
    }
    PGresult *res = PQexec(pg, sql);
    char *out = nyra_pq_strdup("");
    if (PQresultStatus(res) == PGRES_TUPLES_OK && PQntuples(res) > 0) {
        const char *v = PQgetvalue(res, 0, 0);
        free(out);
        out = nyra_pq_strdup(v ? v : "");
    }
    PQclear(res);
    return out ? out : nyra_pq_strdup("");
}

void pq_close(void *conn) {
    PGconn *pg = (PGconn *)conn;
    if (pg) {
        PQfinish(pg);
    }
}

void pq_free_string(char *s) {
    if (s) {
        free(s);
    }
}

int ptr_is_null(void *p) {
    return p == NULL ? 1 : 0;
}
