extends Control

# --- GAME STATS ---
@export_group("Player Stats")
@export var player_hp: int = 20
@export var player_atk: int = 2
@export var player_mp: int = 3

@export_group("Enemy Stats")
@export var enemy_name: String = "The Rat"
@export var enemy_hp: int = 15
@export var enemy_atk: int = 2

func _ready():
	update_ui()
	$CombatZone/EnemySide/EnemyName.text = enemy_name
	print("System: Dice Clash MVP Initialized.")

func update_ui():
	$CombatZone/PlayerSide/CharacterHP.text = "HP: " + str(player_hp)
	$CombatZone/PlayerSide/CharacterMP.text = "MP: " + str(player_mp)
	$CombatZone/EnemySide/EnemyHP.text = "HP: " + str(enemy_hp)

func _on_roll_button_pressed():
	# 1. YOUR TURN TO ATTACK
	var p_roll = randi_range(1, 10)
	var hit_chance = 4 
	
	if p_roll >= hit_chance:
		var damage = player_atk + randi_range(1, 3)
		enemy_hp -= damage
		$CombatZone/CenterSpace/ResultLabel.text = "YOU HIT! Dealt " + str(damage) + " dmg."
	else:
		$CombatZone/CenterSpace/ResultLabel.text = "YOU MISSED the Rat!"
	
	update_ui()
	
	# 2. CHECK IF RAT IS DEAD
	if enemy_hp <= 0:
		handle_victory()
		return

	# 3. THE RAT'S TURN TO ATTACK
	var e_roll = randi_range(1, 10)
	var player_dodge_chance = 5
	
	if e_roll >= player_dodge_chance:
		var e_damage = enemy_atk
		player_hp -= e_damage
		$CombatZone/CenterSpace/ResultLabel.text += "\nRat bit you for " + str(e_damage) + " dmg!"
	else:
		$CombatZone/CenterSpace/ResultLabel.text += "\nRat MISSED you!"

	update_ui()
	
	# 4. CHECK IF YOU DIED
	if player_hp <= 0:
		$CombatZone/CenterSpace/ResultLabel.text = "YOU DIED..."
		$CombatZone/CenterSpace/RollButton.disabled = true
		$CombatZone/CenterSpace/MagicButton.disabled = true
		$CombatZone/CenterSpace/RestartButton.visible = true

func _on_magic_button_pressed():
	if player_mp > 0:
		player_mp -= 1
		enemy_hp -= 6
		$CombatZone/CenterSpace/ResultLabel.text = "MAGIC! Dealt 6 dmg."
		update_ui()
		
		if enemy_hp <= 0:
			handle_victory()
	else:
		$CombatZone/CenterSpace/ResultLabel.text = "OUT OF MP!"

func _on_restart_button_pressed():
	print("RESTART CLICKED!")
	get_tree().reload_current_scene()

func handle_victory():
	$CombatZone/CenterSpace/ResultLabel.text = "VICTORY! The Rat is defeated."
	$CombatZone/CenterSpace/RollButton.disabled = true
	$CombatZone/CenterSpace/MagicButton.disabled = true
	$CombatZone/CenterSpace/RestartButton.visible = true
