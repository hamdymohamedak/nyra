package main

import "fmt"

func main() {
	var sum int64 = 0
	const n int64 = 375_000_000
	const mod int64 = 1_000_000_007
	for i := int64(0); i < n; i++ {
		sum = (sum + i) % mod
	}
	fmt.Println(sum)
}
