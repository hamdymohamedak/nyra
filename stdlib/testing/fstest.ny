import "../testing.ny"
import "../strings.ny"
import "../fs.ny"

fn assert_file_contains(path: string, needle: string) -> void {
    let data = read_file(path)
    if strstr_pos(data, needle) < 0 {
        test_fail("assert_file_contains failed")
    }
}

fn assert_file_exists(path: string) -> void {
    if file_exists(path) == 0 {
        test_fail("assert_file_exists failed")
    }
}

fn assert_file_not_exists(path: string) -> void {
    if file_exists(path) != 0 {
        test_fail("assert_file_not_exists failed")
    }
}
