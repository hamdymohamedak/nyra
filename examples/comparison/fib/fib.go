package main

import "fmt"

func main() {
	const steps int64 = 375_000_000
	const mod int64 = 1_000_000_007
	var a, b int64 = 0, 1
	for i := int64(0); i < steps; i++ {
		t := (a + b) % mod
		a = b
		b = t
	}
	fmt.Println(b)
}
