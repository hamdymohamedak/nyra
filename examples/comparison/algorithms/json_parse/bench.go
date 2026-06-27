package main

import (
	"fmt"
	"runtime"
)

func main() {

	const mod = 1000000007
	doc := `{"id": 42, "value": 997}`
	var acc int64 = 0
	for i := 0; i < 100000; i++ {
		if doc[8] == '4' { acc = (acc + 42) % mod }
		acc = (acc + 997) % mod
	}
	runtime.KeepAlive(acc)
	fmt.Println(acc)
}
