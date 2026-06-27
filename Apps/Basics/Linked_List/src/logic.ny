struct IntList {
    data: ptr
}

fn IntList_new(){
    return IntList { data: Vec_i32_new() }
}

fn IntList_push_back(list, value){
    Vec_i32_push(list.data, value)
    return list
}

fn IntList_len(list){
    return Vec_i32_len(list.data)
}

fn IntList_get(list, index){
    return Vec_i32_get(list.data, index)
}

fn IntList_sum(list){
    let mut total = 0
    let mut i = 0
    let len = IntList_len(list)
    while i < len {
        total = total + IntList_get(list, i)
        i = i + 1
    }
    return total
}

fn IntList_free(list){
    Vec_i32_free(list.data)
}

fn LinkedList_run(){
    let mut list = IntList_new()
    list = IntList_push_back(list, 10)
    list = IntList_push_back(list, 20)
    list = IntList_push_back(list, 30)
    print(`length: ${IntList_len(list)}`)
    print(`sum: ${IntList_sum(list)}`)
    let mut i = 0
    while i < IntList_len(list) {
        print(`[${i}] = ${IntList_get(list, i)}`)
        i = i + 1
    }
    IntList_free(list)
}
