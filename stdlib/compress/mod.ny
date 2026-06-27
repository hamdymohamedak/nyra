import "../strings.ny"
import "../archive/zip.ny"

const RLE_MAGIC = "NYR1|"

extern fn gzip_compress_hex(data: string) -> string
extern fn gzip_decompress_hex(hex: string) -> string
extern fn read_file(path: string) -> string
extern fn write_file(path: string, content: string) -> i32
extern fn file_exists(path: string) -> i32

fn rle_compress(data: string) -> string {
    let n = strlen(data)
    if n == 0 {
        return RLE_MAGIC
    }
    let mut out = RLE_MAGIC
    let mut i = 0
    while i < n {
        let c = char_at(data, i)
        let mut run = 1
        while i + run < n {
            if char_at(data, i + run) != c {
                break
            }
            if run >= 127 {
                break
            }
            run = run + 1
        }
        if run >= 4 {
            let head = strcat("*", i32_to_string(run))
            let ch = substring(data, i, 1)
            out = strcat(strcat(out, head), ch)
        } else {
            let mut j = 0
            while j < run {
                let ch = substring(data, i + j, 1)
                if strcmp(ch, "*") == 0 {
                    out = strcat(out, "\\*")
                } else {
                    out = strcat(out, ch)
                }
                j = j + 1
            }
        }
        i = i + run
    }
    return out
}

fn rle_decompress(data: string) -> string {
    if strcmp(substring(data, 0, 5), RLE_MAGIC) != 0 {
        return data
    }
    let mut out = ""
    let n = strlen(data)
    let mut i = 5
    while i < n {
        let c = char_at(data, i)
        if c == 92 && i + 1 < n {
            let next = substring(data, i + 1, 1)
            out = strcat(out, next)
            i = i + 2
        } else {
            if c == 42 {
                let mut run = 0
                i = i + 1
                while i < n {
                    let d = char_at(data, i)
                    if d >= 48 && d <= 57 {
                        run = run * 10 + (d - 48)
                        i = i + 1
                    } else {
                        break
                    }
                }
                if i < n {
                    let ch = substring(data, i, 1)
                    let mut j = 0
                    while j < run {
                        out = strcat(out, ch)
                        j = j + 1
                    }
                    i = i + 1
                }
            } else {
                out = strcat(out, substring(data, i, 1))
                i = i + 1
            }
        }
    }
    return out
}

fn gzip_compress(data: string) -> string {
    return gzip_compress_hex(data)
}

fn gzip_decompress(data: string) -> string {
    return gzip_decompress_hex(data)
}

fn zip_create(archive_path: string, source_path: string) -> i32 {
    return zip_pack(archive_path, source_path, source_path)
}

fn zip_extract(archive_path: string, dest_path: string) -> i32 {
    return zip_unpack(archive_path, dest_path)
}
