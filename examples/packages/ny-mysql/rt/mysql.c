#include <mysql/mysql.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static char *nyra_mysql_strdup(const char *s) {
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

void *mysql_connect(const char *spec) {
    if (!spec) {
        return NULL;
    }
    char host[128] = "127.0.0.1";
    char user[128] = "root";
    char pass[128] = "";
    char dbname[128] = "";
    unsigned int port = 3306;
    sscanf(spec, "%127[^;];%u;%127[^;];%127[^;];%127[^;]", host, &port, dbname, user, pass);
    MYSQL *my = mysql_init(NULL);
    if (!my || !mysql_real_connect(my, host, user, pass, dbname, port, NULL, 0)) {
        if (my) {
            mysql_close(my);
        }
        return NULL;
    }
    return my;
}

int mysql_exec(void *conn, const char *sql) {
    MYSQL *my = (MYSQL *)conn;
    if (!my || !sql) {
        return -1;
    }
    return mysql_query(my, sql) == 0 ? 0 : -1;
}

char *mysql_query_scalar(void *conn, const char *sql) {
    MYSQL *my = (MYSQL *)conn;
    if (!my || !sql) {
        return nyra_mysql_strdup("");
    }
    if (mysql_query(my, sql) != 0) {
        return nyra_mysql_strdup("");
    }
    MYSQL_RES *res = mysql_store_result(my);
    char *out = nyra_mysql_strdup("");
    if (res) {
        MYSQL_ROW row = mysql_fetch_row(res);
        if (row && row[0]) {
            free(out);
            out = nyra_mysql_strdup(row[0]);
        }
        mysql_free_result(res);
    }
    return out ? out : nyra_mysql_strdup("");
}

void mysql_close(void *conn) {
    MYSQL *my = (MYSQL *)conn;
    if (my) {
        mysql_close(my);
    }
}

void mysql_free_string(char *s) {
    if (s) {
        free(s);
    }
}

int ptr_is_null(void *p) {
    return p == NULL ? 1 : 0;
}
