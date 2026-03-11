class_name Score
extends Node

var score: int = 0 : set = setScore, get = getScore

func setScore(value: int):
	score = value
	
func getScore() -> int:
	return score
