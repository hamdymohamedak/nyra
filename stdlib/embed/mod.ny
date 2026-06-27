import "../map.ny"
import "../strings.ny"
import "../fs.ny"
import "../vec_str.ny"

struct EmbedFs {
    inner: HashMap_str_str
}

fn EmbedFs_new() -> EmbedFs {
    return EmbedFs { inner: HashMap_str_str_new() }
}

impl EmbedFs {
    fn add(self, name: string, content: string) -> EmbedFs {
        let inner = self.inner.insert(name, content)
        return EmbedFs { inner: inner }
    }

    fn read(self, name: string) -> string {
        if self.inner.contains(name) != 0 {
            return self.inner.get(name)
        }
        return read_file(name)
    }
}

fn embed_read_file(fs: EmbedFs, name: string) -> string {
    return fs.read(name)
}

fn embed_from_manifest(fs: EmbedFs, manifest_path: string) -> EmbedFs {
    let text = read_file(manifest_path)
    let lines = StrVec_from_lines(text)
    let n = lines.len()
    let mut out = fs
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        if strlen(line) > 0 {
            let content = read_file(line)
            out = out.add(line, content)
        }
        i = i + 1
    }
    return out
}
