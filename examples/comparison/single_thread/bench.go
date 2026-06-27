package main

import (
	"fmt"
	"runtime"
)

func main() {
	var sum int64
	const N = 200
	for i := int64(0); i < N; i++ {
		for j := int64(0); j < N; j++ {
			sum += i * j
		}
	}
	runtime.KeepAlive(sum)
	fmt.Println(sum)
}
