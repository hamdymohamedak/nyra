// Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.
package main

import "fmt"

const (
	grid        = 4
	startHP     = 100
	maxTurns    = 24
	trapDamage  = 25
	goldValue   = 15
	goalBonus   = 50
	appTitle    = "Dungeon Steps"
	statusPlaying = 0
	statusWon     = 1
	statusLost    = 2
)

type tile int

const (
	tileFloor tile = iota
	tileTrap
	tileGold
	tileGoal
)

type dir int

const (
	dirNorth dir = iota
	dirEast
	dirSouth
	dirWest
)

type gameState struct {
	x, y, hp, score, turn, status int32
}

func tileAt(x, y int32) tile {
	if x == 3 && y == 3 {
		return tileGoal
	}
	if x == 1 && y == 1 {
		return tileTrap
	}
	if x == 2 && y == 1 {
		return tileGold
	}
	if x == 1 && y == 3 {
		return tileGold
	}
	return tileFloor
}

func clampAxis(v int32) int32 {
	if v < 0 {
		return 0
	}
	if v >= grid {
		return grid - 1
	}
	return v
}

func turnPhase(turn int32) int32 {
	return turn % 4
}

func dirForTurn(turn int32) dir {
	switch turnPhase(turn) {
	case 0, 1:
		return dirEast
	default:
		return dirSouth
	}
}

func newGame() gameState {
	return gameState{x: 0, y: 0, hp: startHP, score: 0, turn: 0, status: statusPlaying}
}

func isPlaying(game gameState) int32 {
	if game.status == statusPlaying {
		return 1
	}
	return 0
}

func copyGame(x, y, hp, score, turn, status int32) gameState {
	return gameState{x: x, y: y, hp: hp, score: score, turn: turn, status: status}
}

func trapHP(hp int32) int32 {
	h := hp - trapDamage
	if h <= 0 {
		return 0
	}
	return h
}

func trapStatus(hp, playing int32) int32 {
	h := hp - trapDamage
	if h <= 0 {
		return statusLost
	}
	return playing
}

func applyTileAt(sx, sy, shp, sscore, sturn, sstatus int32, t tile) gameState {
	switch t {
	case tileFloor:
		return copyGame(sx, sy, shp, sscore, sturn, sstatus)
	case tileGold:
		return copyGame(sx, sy, shp, sscore+goldValue, sturn, sstatus)
	case tileGoal:
		return copyGame(sx, sy, shp, sscore+goalBonus, sturn, statusWon)
	case tileTrap:
		return copyGame(sx, sy, trapHP(shp), sscore, sturn, trapStatus(shp, sstatus))
	default:
		return copyGame(sx, sy, shp, sscore, sturn, sstatus)
	}
}

func advanceParts(sx, sy, shp, sscore, sturn, sstatus, dx, dy int32) gameState {
	nx := clampAxis(sx + dx)
	ny := clampAxis(sy + dy)
	return applyTileAt(nx, ny, shp, sscore, sturn+1, sstatus, tileAt(nx, ny))
}

func movePlayer(game gameState, d dir) gameState {
	sx, sy := game.x, game.y
	shp, sscore := game.hp, game.score
	sturn, sstatus := game.turn, game.status
	switch d {
	case dirEast:
		return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
	case dirWest:
		return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
	case dirNorth:
		return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
	case dirSouth:
		return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
	default:
		return game
	}
}

func stepTurn(game gameState) gameState {
	sx, sy := game.x, game.y
	shp, sscore := game.hp, game.score
	sturn, sstatus := game.turn, game.status
	if sstatus == statusPlaying {
		switch dirForTurn(sturn) {
		case dirEast:
			return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
		case dirWest:
			return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
		case dirNorth:
			return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
		case dirSouth:
			return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
		}
	}
	return copyGame(sx, sy, shp, sscore, sturn, sstatus)
}

func runDungeon() int32 {
	game := newGame()
	for isPlaying(game) != 0 && game.turn < maxTurns {
		game = stepTurn(game)
	}
	if isPlaying(game) == 0 {
		return game.score
	}
	lost := copyGame(game.x, game.y, game.hp, game.score, game.turn, statusLost)
	return lost.score
}

func outcomeCode(game gameState) int32 {
	return game.status
}

func main() {
	fmt.Println(appTitle)
	fmt.Println(runDungeon())
	g0 := newGame()
	g1 := movePlayer(g0, dirEast)
	fmt.Println(outcomeCode(g1))
	var banner int32
	for i := int32(0); i < 3; i++ {
		banner = banner + i
	}
	fmt.Println(banner)
}
