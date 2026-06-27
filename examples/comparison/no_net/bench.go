package main

import "runtime"

func main() {
	var h int32
	const N = 4_000_000
	for i := int32(0); i < N; i++ {
		h = (h + i*31 + 17) % 999983
	}
	runtime.KeepAlive(h)
}
