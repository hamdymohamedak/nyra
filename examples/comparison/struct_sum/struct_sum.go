package main

import "fmt"

type Point struct {
	x int
	y int
}

func main() {
	var sum int64 = 0
	const n = 80_000_000
	p := Point{x: 1, y: 2}
	for i := 0; i < n; i++ {
		sum += int64(p.x + p.y)
	}
	fmt.Println(sum)
}
