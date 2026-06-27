package main

import (
	"fmt"
	"runtime"
)

func main() {
	var sum int64
	const N = 125_000
	for i := int64(0); i < N; i++ {
		sum += i
	}
	runtime.KeepAlive(sum)
	fmt.Println(sum)
}
