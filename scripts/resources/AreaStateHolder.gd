extends Node

class CharStateArray extends Resource:
	var CharacterStateArray:Array[CharState]

@export var AreaStates:Dictionary[String, CharStateArray]
