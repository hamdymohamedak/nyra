// Trait object drop — frees boxed heap data
// nyra test tests/nyra/trait_dyn_drop_test.ny

trait Show {
    fn id(self) -> i32
}

struct Pod {
    n: i32
}

impl Show for Pod {
    fn id(self) -> i32 {
        return self.n
    }
}

fn use_dyn(g: dyn Show) -> i32 {
    return g.id()
}

test fn test_dyn_drop_runs() {
    let p = Pod { n: 99 }
    let v = use_dyn(p as dyn Show)
    assert_eq(v, 99)
}
