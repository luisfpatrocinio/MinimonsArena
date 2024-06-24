extends Node3D

var scoreStruct = ScoreManager.lastGamePlayedScore;

@export var SCENE_TITLE = "RESULTADOS DA RUN"

@onready var label = $Label3D

func _ready() -> void:
	showResults();
	

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.transitionTo("title")

# Função responsável por ler a última score e mostrar na tela
func showResults():
	var monsterPlayedKey = scoreStruct.get("monsterPlayedKey")
	#var monsterPlayedName = Global.monsterDict[monsterPlayedKey]["name"]
	var pointsEarned = scoreStruct.get("levelPoints")
	var enemiesKilled = scoreStruct.get("enemiesKilled")
	var stagesSurvived = scoreStruct.get("stagesSurvived")
	
	label.text = SCENE_TITLE + "\n"
	#label.text += "Personagem: %s \n" % [monsterPlayedName]
	label.text += "Inimigos mortos: %d \n" % [enemiesKilled]
	label.text += "Turnos sobrevividos: %d \n" % [stagesSurvived]
	label.text += "PONTOS TOTAIS: %d \n" % [pointsEarned]
