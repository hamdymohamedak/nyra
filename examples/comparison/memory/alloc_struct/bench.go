package main

import (
	"fmt"
	"runtime"
)

func main() {

	const n = 500000
	const mod = 1000000007
	var acc int64 = 0
	for i := int64(0); i < n; i++ {
		x := int64(i % 997)
		y := int64((i * 3) % 991)
		acc = (acc + x + y) % mod
	}
	runtime.KeepAlive(acc)
	fmt.Println(acc)
}
