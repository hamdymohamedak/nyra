import "src/config.ny"
import "src/engine.ny"
import "src/types.ny"

fn main() -> void {
    print(APP_TITLE)
    print(run_dungeon())
    let g0 = new_game()
    let g1 = move_player(g0, Dir.East)
    print(outcome_code(g1))
    let mut banner = 0
    for i in 0..3 {
        banner = banner + i
    }
    print(banner)
}
