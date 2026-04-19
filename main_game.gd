extends Control

# --- GAME STATS ---
@export_group("Player Stats")
@export var player_hp: int = 20
@export var player_atk: int = 5
@export var player_mp: int = 3
var player_current_hp: int = 20

@export_group("Enemy Stats")
@export var enemy_name: String = "The Rat"
@export var enemy_hp: int = 15
@export var enemy_atk: int = 4
var enemy_current_hp: int = 15

# Turn Tracking
var is_player_turn: bool = true

func _ready():
	player_current_hp = player_hp
	enemy_current_hp = enemy_hp
	update_ui()
	$CombatZone/EnemySide/EnemyName.text = enemy_name
	set_turn_ui("Player")

func update_ui():
	# Added AP to the text display here
	$CombatZone/PlayerSide/CharacterHP.text = "HP: " + str(player_current_hp) + " | AP: " + str(player_atk)
	$CombatZone/PlayerSide/CharacterMP.text = "MP: " + str(player_mp)
	
	$CombatZone/EnemySide/EnemyHP.text = "HP: " + str(enemy_current_hp) + " | AP: " + str(enemy_atk)

func set_turn_ui(turn_owner: String):
	if turn_owner == "Player":
		$CombatZone/CenterSpace/RollButton.text = "Your Turn: Attack!"
		$CombatZone/CenterSpace/MagicButton.disabled = false
	else:
		$CombatZone/CenterSpace/RollButton.text = "Enemy Turn: Defend!"
		$CombatZone/CenterSpace/MagicButton.disabled = true

func _on_roll_button_pressed():
	if is_player_turn:
		player_attack_phase()
	else:
		enemy_attack_phase()

func player_attack_phase():
	var p_dice = randi_range(1, 10)
	var e_dice = randi_range(1, 10)
	
	var math_header = "YOU ATTACK!\nRoll: [" + str(p_dice) + "] vs Rat: [" + str(e_dice) + "]"
	var result_text = ""
	
	# Perfectly Fair Logic: Strict Greater Than (Tie = Nothing happens)
	if p_dice > e_dice:
		var diff = p_dice - e_dice
		var total_dmg = diff + player_atk
		enemy_current_hp -= total_dmg
		result_text = "SUCCESS! Dealt " + str(total_dmg) + " damage."
	else:
		result_text = "DEFENDED! The Rat blocked your strike."
	
	$CombatZone/CenterSpace/ResultLabel.text = math_header + "\n" + result_text
	update_ui()
	
	if not check_game_over():
		is_player_turn = false
		set_turn_ui("Enemy")

func enemy_attack_phase():
	var e_dice = randi_range(1, 10)
	var p_dice = randi_range(1, 10)
	
	var math_header = "RAT ATTACKS!\nRat: [" + str(e_dice) + "] vs You: [" + str(p_dice) + "]"
	var result_text = ""
	
	# Perfectly Fair Logic: Strict Greater Than (Tie = Nothing happens)
	if e_dice > p_dice:
		var diff = e_dice - p_dice
		var total_dmg = diff + enemy_atk
		player_current_hp -= total_dmg
		result_text = "HIT! You took " + str(total_dmg) + " damage."
	else:
		result_text = "DEFENDED! You parried the Rat's claws."
	
	$CombatZone/CenterSpace/ResultLabel.text = math_header + "\n" + result_text
	update_ui()
	
	if not check_game_over():
		is_player_turn = true
		set_turn_ui("Player")

func _on_magic_button_pressed():
	if is_player_turn and player_mp > 0:
		player_mp -= 1
		var magic_dmg = 8
		enemy_current_hp -= magic_dmg
		$CombatZone/CenterSpace/ResultLabel.text = "MAGIC BURST!\nDealt " + str(magic_dmg) + " pure damage."
		update_ui()
		
		if not check_game_over():
			is_player_turn = false
			set_turn_ui("Enemy")

func check_game_over() -> bool:
	if enemy_current_hp <= 0:
		handle_victory()
		return true
	elif player_current_hp <= 0:
		handle_death()
		return true
	return false

func handle_victory():
	$CombatZone/CenterSpace/ResultLabel.text += "\n\nVICTORY! The Rat is defeated."
	$CombatZone/CenterSpace/RollButton.disabled = true
	$CombatZone/CenterSpace/MagicButton.disabled = true
	$CombatZone/CenterSpace/RestartButton.visible = true

func handle_death():
	$CombatZone/CenterSpace/ResultLabel.text += "\n\nYOU DIED... The quest ends."
	$CombatZone/CenterSpace/RollButton.disabled = true
	$CombatZone/CenterSpace/MagicButton.disabled = true
	$CombatZone/CenterSpace/RestartButton.visible = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
