import "../core/types.ny"
import "../core/id.ny"

extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn map_str_i32_get(m: ptr, key: string) -> i32
extern fn map_str_i32_contains(m: ptr, key: string) -> i32

struct PaneNode {
    id: i32
    kind: PaneKind
    tab_id: i32
    left_id: i32
    right_id: i32
    ratio: i32
}

fn PaneKind_to_i32(k){
    return match k {
        PaneKind.Leaf => 0
        PaneKind.SplitH => 1
        PaneKind.SplitV => 2
    }
}

fn PaneKind_from_i32(n){
    if n == 1 { return PaneKind.SplitH }
    if n == 2 { return PaneKind.SplitV }
    return PaneKind.Leaf
}

struct LayoutManager {
    root_id: i32
    kinds: ptr
    tabs: ptr
    lefts: ptr
    rights: ptr
    ratios: ptr
    ids: IdGen
    count: i32
}

fn LayoutManager_new(){
    return LayoutManager {
        root_id: 0
        kinds: map_str_i32_new()
        tabs: map_str_i32_new()
        lefts: map_str_i32_new()
        rights: map_str_i32_new()
        ratios: map_str_i32_new()
        ids: IdGen_new()
        count: 0
    }
}

fn LayoutManager_write(layout, node){
    let key = Id_to_key(node.id)
    map_str_i32_insert(layout.kinds, key, PaneKind_to_i32(node.kind))
    map_str_i32_insert(layout.tabs, key, node.tab_id)
    map_str_i32_insert(layout.lefts, key, node.left_id)
    map_str_i32_insert(layout.rights, key, node.right_id)
    map_str_i32_insert(layout.ratios, key, node.ratio)
}

fn LayoutManager_create_leaf(layout, tab_id){
    let id = IdGen_take(layout.ids)
    let node = PaneNode {
        id: id
        kind: PaneKind.Leaf
        tab_id: tab_id
        left_id: 0
        right_id: 0
        ratio: 50
    }
    LayoutManager_write(layout, node)
    let root = if layout.root_id == 0 { id } else { layout.root_id }
    return LayoutManager {
        root_id: root
        kinds: layout.kinds
        tabs: layout.tabs
        lefts: layout.lefts
        rights: layout.rights
        ratios: layout.ratios
        ids: IdGen_next(layout.ids)
        count: layout.count + 1
    }
}

fn LayoutManager_split(layout, pane_id, dir, new_tab_id){
    let key = Id_to_key(pane_id)
    if map_str_i32_contains(layout.kinds, key) == 0 {
        return layout
    }
    let new_leaf_id = IdGen_take(layout.ids)
    let leaf = PaneNode {
        id: new_leaf_id
        kind: PaneKind.Leaf
        tab_id: new_tab_id
        left_id: 0
        right_id: 0
        ratio: 50
    }
    LayoutManager_write(layout, leaf)
    let ids_after_leaf = IdGen_next(layout.ids)
    let split_id = IdGen_take(ids_after_leaf)
    let kind = if dir == SplitDirection.Horizontal { PaneKind.SplitH } else { PaneKind.SplitV }
    let split = PaneNode {
        id: split_id
        kind: kind
        tab_id: 0
        left_id: pane_id
        right_id: new_leaf_id
        ratio: 50
    }
    LayoutManager_write(layout, split)
    return LayoutManager {
        root_id: if layout.root_id == pane_id { split_id } else { layout.root_id }
        kinds: layout.kinds
        tabs: layout.tabs
        lefts: layout.lefts
        rights: layout.rights
        ratios: layout.ratios
        ids: IdGen_next(ids_after_leaf)
        count: layout.count + 2
    }
}

fn LayoutManager_print_tree(layout, node_id, depth){
    if node_id == 0 {
        return
    }
    let key = Id_to_key(node_id)
    let kind = PaneKind_from_i32(map_str_i32_get(layout.kinds, key))
    if kind == PaneKind.Leaf {
        let tab_id = map_str_i32_get(layout.tabs, key)
        print(`  pane #${node_id} leaf -> tab #${tab_id}`)
    } else {
        let label = if kind == PaneKind.SplitH { "split-h" } else { "split-v" }
        print(`  pane #${node_id} ${label} ratio=${map_str_i32_get(layout.ratios, key)}`)
        LayoutManager_print_tree(layout, map_str_i32_get(layout.lefts, key), depth + 1)
        LayoutManager_print_tree(layout, map_str_i32_get(layout.rights, key), depth + 1)
    }
}

fn LayoutManager_print(layout){
    print("layout tree:")
    LayoutManager_print_tree(layout, layout.root_id, 0)
}
