package main

import "runtime"

func main() {
	var acc int32
	const N = 5_000_000
	for i := int32(0); i < N; i++ {
		acc = (acc + i) % 999983
	}
	runtime.KeepAlive(acc)
}
