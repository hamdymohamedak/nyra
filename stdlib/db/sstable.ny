// Immutable sorted-string table (SST) — append-only on-disk key/value blocks.

const SST_MAGIC = "SST1\n"
const SST_END = "END\n"

struct SsTable {
    path: string
}

fn SsTable_new(path: string) -> SsTable {
    return SsTable { path: path }
}

fn SsTable_encode_row(key: string, value: string) -> string {
    return strcat(key, strcat("\t", strcat(value, "\n")))
}

fn SsTable_build_body(keys: StrVec, values: StrVec) -> string {
    let n = keys.len()
    let mut body = ""
    let mut i = 0
    while i < n {
        body = strcat(body, SsTable_encode_row(clone keys.get(i), clone values.get(i)))
        i = i + 1
    }
    return body
}

fn SsTable_write_sorted(table: SsTable, keys: StrVec, values: StrVec) -> i32 {
    let body = SsTable_build_body(keys, values)
    let text = strcat(SST_MAGIC, strcat(body, SST_END))
    return write_file(table.path, text)
}

fn SsTable_fsync(table: SsTable) -> i32 {
    return fsync_file(table.path)
}

fn SsTable_load_pairs(table: SsTable) -> StrVec {
    if exists(table.path) == 0 {
        return StrVec_new()
    }
    let raw = read_file(table.path)
    if strstr_pos(raw, SST_MAGIC) != 0 {
        return StrVec_new()
    }
    let start = strlen(SST_MAGIC)
    let end_pos = strstr_pos(raw, SST_END)
    if end_pos < 0 {
        return StrVec_new()
    }
    let body = substring(raw, start, end_pos - start)
    return StrVec_from_lines(body)
}

fn SsTable_get(table: SsTable, key: string) -> string {
    let rows = SsTable_load_pairs(table)
    let n = rows.len()
    let mut lo = 0
    let mut hi = n
    while lo < hi {
        let mid = (lo + hi) / 2
        let line = clone rows.get(mid)
        let tab = strstr_pos(line, "\t")
        if tab < 0 {
            return ""
        }
        let k = substring(line, 0, tab)
        let cmp = strcmp(k, key)
        if cmp == 0 {
            return substring(line, tab + 1, strlen(line) - tab - 1)
        }
        if cmp < 0 {
            lo = mid + 1
        } else {
            hi = mid
        }
    }
    return ""
}

fn SsTable_row_key(line) {
    let tab = strstr_pos(line, "\t")
    if tab < 0 {
        return ""
    }
    return substring(line, 0, tab)
}

fn SsTable_row_value(line) {
    let tab = strstr_pos(line, "\t")
    if tab < 0 {
        return ""
    }
    return substring(line, tab + 1, strlen(line) - tab - 1)
}

fn sstable_merge_files(out_path: string, path_a: string, path_b: string) -> i32 {
    let rows_a = SsTable_load_pairs(SsTable_new(path_a))
    let rows_b = SsTable_load_pairs(SsTable_new(path_b))
    let na = rows_a.len()
    let nb = rows_b.len()
    let mut keys = StrVec_new()
    let mut vals = StrVec_new()
    let mut ia = 0
    let mut ib = 0
    while ia < na || ib < nb {
        if ia >= na {
            let line = clone rows_b.get(ib)
            keys = keys.push(SsTable_row_key(line))
            vals = vals.push(SsTable_row_value(line))
            ib = ib + 1
        } else {
            if ib >= nb {
                let line = clone rows_a.get(ia)
                keys = keys.push(SsTable_row_key(line))
                vals = vals.push(SsTable_row_value(line))
                ia = ia + 1
            } else {
                let ka = SsTable_row_key(clone rows_a.get(ia))
                let kb = SsTable_row_key(clone rows_b.get(ib))
                let cmp = strcmp(ka, kb)
                if cmp < 0 {
                    keys = keys.push(ka)
                    vals = vals.push(SsTable_row_value(clone rows_a.get(ia)))
                    ia = ia + 1
                } else {
                    if cmp > 0 {
                        keys = keys.push(kb)
                        vals = vals.push(SsTable_row_value(clone rows_b.get(ib)))
                        ib = ib + 1
                    } else {
                        keys = keys.push(ka)
                        vals = vals.push(SsTable_row_value(clone rows_b.get(ib)))
                        ia = ia + 1
                        ib = ib + 1
                    }
                }
            }
        }
    }
    SsTable_write_sorted(SsTable_new(out_path), keys, vals)
    return 0
}

impl SsTable {
    fn write_sorted(self, keys: StrVec, values: StrVec) -> i32 {
        return SsTable_write_sorted(self, keys, values)
    }

    fn fsync(self) -> i32 {
        return SsTable_fsync(self)
    }

    fn load_pairs(self) -> StrVec {
        return SsTable_load_pairs(self)
    }

    fn get(self, key: string) -> string {
        return SsTable_get(self, key)
    }

    fn merge_files(self, path_a: string, path_b: string) -> i32 {
        return sstable_merge_files(self.path, path_a, path_b)
    }
}

extern fn fsync_file(path: string) -> i32
