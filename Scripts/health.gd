class_name Health
extends Node

signal healthMaxChanged(diff: float)
signal healthChanged(diff: float)
signal healthEmpty

@export var maxHealth: float =  100.0 : set = setMaxHealth, get = getMaxHealth
@export var invulerable: bool = false : set = setInvul, get = getInvul
@export var iFrameLength: float = 2.0

var iFrameTimer: Timer = null

@onready var health: float = maxHealth : set = setHealth, get = getHealth

# Setters
func setMaxHealth(max: float):
	# Clamp value
	var value = 1.0 
	if max > 0:
		value = max
	
	# Set max health
	if value != maxHealth:
		var diff = value - maxHealth
		maxHealth = value
		healthMaxChanged.emit(diff)
	
	# Clamp health
	if health > maxHealth:
		health = maxHealth
	
func setHealth(hp: float):
	
	# Invulerablity check
	if hp < health && invulerable:
		return
	
	# Clamp value
	var value = clampf(hp, 0, maxHealth)
	
	# Set health
	if value != health:
		var diff = value - health
		health = value;
		healthChanged.emit(diff)
	
	# Depeletion Check
	if health == 0:
		healthEmpty.emit()

func setInvul(state: bool):
	invulerable = state

# Getters
func getMaxHealth() -> float:
	return maxHealth

func getHealth() -> float:
	return health

func getInvul() -> bool:
	return invulerable
	
# Functions
func temporaryInvul(secs: float):
	# Existance Check
	if iFrameTimer == null:
		iFrameTimer = Timer.new()
		iFrameTimer.one_shot = true
		iFrameTimer.name = "IFrameTimer"
		add_child(iFrameTimer)
	
	# Reset
	if iFrameTimer.timeout.is_connected(setInvul):
		iFrameTimer.timeout.disconnect(setInvul)
		
	# Start Timer
	iFrameTimer.timeout.connect(setInvul.bind(false))
	invulerable = true
	iFrameTimer.start(iFrameLength)
