#include <sqlite3.h>
#include <stdlib.h>
#include <string.h>

typedef struct SqliteRowset {
    int cols;
    int rows;
    char **cells;
} SqliteRowset;

static char *sqlite_strdup(const char *s) {
    if (!s) {
        s = "";
    }
    size_t n = strlen(s);
    char *out = (char *)malloc(n + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, s, n + 1);
    return out;
}

int sqlite_exec(void *handle, const char *sql) {
    sqlite3 *db = (sqlite3 *)handle;
    if (!db || !sql) {
        return -1;
    }
    char *err = NULL;
    int rc = sqlite3_exec(db, sql, NULL, NULL, &err);
    if (err) {
        sqlite3_free(err);
    }
    return rc == SQLITE_OK ? 0 : rc;
}

void *sqlite_open(const char *path) {
    sqlite3 *db = NULL;
    if (!path || sqlite3_open(path, &db) != SQLITE_OK) {
        if (db) {
            sqlite3_close(db);
        }
        return NULL;
    }
    return db;
}

void sqlite_close(void *handle) {
    sqlite3 *db = (sqlite3 *)handle;
    if (db) {
        sqlite3_close(db);
    }
}

const char *sqlite_last_error(void *handle) {
    sqlite3 *db = (sqlite3 *)handle;
    if (!db) {
        return "sqlite: null handle";
    }
    const char *msg = sqlite3_errmsg(db);
    return msg ? msg : "";
}

void *sqlite_prepare(void *handle, const char *sql) {
    sqlite3 *db = (sqlite3 *)handle;
    if (!db || !sql) {
        return NULL;
    }
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return NULL;
    }
    return stmt;
}

int sqlite_step(void *stmt) {
    if (!stmt) {
        return -1;
    }
    int rc = sqlite3_step((sqlite3_stmt *)stmt);
    if (rc == SQLITE_ROW) {
        return 1;
    }
    if (rc == SQLITE_DONE) {
        return 0;
    }
    return -1;
}

int sqlite_column_count(void *stmt) {
    if (!stmt) {
        return 0;
    }
    return sqlite3_column_count((sqlite3_stmt *)stmt);
}

const char *sqlite_column_text(void *stmt, int col) {
    if (!stmt || col < 0) {
        return "";
    }
    const char *v = (const char *)sqlite3_column_text((sqlite3_stmt *)stmt, col);
    return v ? v : "";
}

void sqlite_finalize(void *stmt) {
    if (stmt) {
        sqlite3_finalize((sqlite3_stmt *)stmt);
    }
}

void *sqlite_query_rows(void *handle, const char *sql) {
    sqlite3 *db = (sqlite3 *)handle;
    if (!db || !sql) {
        return NULL;
    }
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        return NULL;
    }
    SqliteRowset *rs = (SqliteRowset *)calloc(1, sizeof(SqliteRowset));
    if (!rs) {
        sqlite3_finalize(stmt);
        return NULL;
    }
    rs->cols = sqlite3_column_count(stmt);
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int row = rs->rows++;
        size_t need = (size_t)(row + 1) * (size_t)rs->cols * sizeof(char *);
        char **next = (char **)realloc(rs->cells, need);
        if (!next) {
            break;
        }
        rs->cells = next;
        int base = row * rs->cols;
        for (int i = 0; i < rs->cols; i++) {
            const char *v = (const char *)sqlite3_column_text(stmt, i);
            rs->cells[base + i] = sqlite_strdup(v);
        }
    }
    sqlite3_finalize(stmt);
    return rs;
}

int sqlite_rowset_rows(void *rowset) {
    if (!rowset) {
        return 0;
    }
    return ((SqliteRowset *)rowset)->rows;
}

int sqlite_rowset_cols(void *rowset) {
    if (!rowset) {
        return 0;
    }
    return ((SqliteRowset *)rowset)->cols;
}

const char *sqlite_rowset_at(void *rowset, int row, int col) {
    SqliteRowset *rs = (SqliteRowset *)rowset;
    if (!rs || row < 0 || row >= rs->rows || col < 0 || col >= rs->cols) {
        return "";
    }
    char *cell = rs->cells[row * rs->cols + col];
    return cell ? cell : "";
}

void sqlite_rowset_free(void *rowset) {
    SqliteRowset *rs = (SqliteRowset *)rowset;
    if (!rs) {
        return;
    }
    if (rs->cells) {
        int total = rs->rows * rs->cols;
        for (int i = 0; i < total; i++) {
            free(rs->cells[i]);
        }
        free(rs->cells);
    }
    free(rs);
}
