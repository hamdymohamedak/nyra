package main

import (
	"fmt"
	"runtime"
)

func main() {

	const n = 5000
	const mod = 1000000007
	var acc int64 = int64(n) % mod
	_ = acc
	runtime.KeepAlive(acc)
	fmt.Println(acc)
}
