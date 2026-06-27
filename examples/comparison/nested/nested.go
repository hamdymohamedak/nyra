package main

import "fmt"

func main() {
	var sum int64 = 0
	const n = 4000
	const mod int64 = 1_000_000_007
	for i := 0; i < n; i++ {
		for j := 0; j < n; j++ {
			sum = (sum + int64(i*j)) % mod
		}
	}
	fmt.Println(sum)
}
