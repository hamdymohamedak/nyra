package main

import "fmt"

func main() {
	var acc int64 = 0
	const n int64 = 270_000_000
	const mod int64 = 1_000_000_007
	for i := int64(0); i < n; i++ {
		t := (i % 997) * 31
		acc = (acc + t + (acc % 4099)) % mod
	}
	fmt.Println(acc)
}
