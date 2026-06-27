package main

import "runtime"

func main() {
	var x, y, acc int32 = 1, 2, 0
	const N = 5_000_000
	for i := int32(0); i < N; i++ {
		acc += x + y
		x++
		y++
	}
	runtime.KeepAlive(acc)
}
