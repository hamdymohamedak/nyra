package main

import (
	"fmt"
	"runtime"
)

func main() {
	const n = 40
	a, b := 0, 1
	for i := 0; i < n; i++ {
		a, b = b, a+b
	}
	runtime.KeepAlive(b)
	fmt.Println(b)
}
