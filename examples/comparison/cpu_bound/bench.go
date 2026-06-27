package main

import (
	"fmt"
	"runtime"
)

func main() {
	var acc int64 = 0
	const n int64 = 180_000_000
	for i := int64(0); i < n; i++ {
		term := (i % 997) * 31
		acc = (acc + term) % 997
	}
	runtime.KeepAlive(acc)
	fmt.Println(acc)
}
