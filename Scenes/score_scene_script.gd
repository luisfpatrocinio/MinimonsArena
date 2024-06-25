extends CanvasLayer

var scoreStruct = ScoreManager.lastGamePlayedScore;

@export var SCENE_TITLE: String = "RESULTADOS DA RUN"

@onready var label = %resultsText
@onready var score = $Score
@onready var sceneTitle = %SceneTitle

func _ready() -> void:
	showResults();
	fadeIn();
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		Global.transitionTo("title")

# Função responsável por ler a última score e mostrar na tela
func showResults():
	var monsterPlayedKey = scoreStruct.get("monsterPlayedKey")
	var monsterPlayedName = Global.monsterDict.get(monsterPlayedKey, {}).get("name", "NOT_FOUND")
	var pointsEarned = scoreStruct.get("levelPoints", 0)
	var enemiesKilled = scoreStruct.get("enemiesKilled", 0)
	var stagesSurvived = scoreStruct.get("stagesSurvived", 0)
	
	sceneTitle.text = tr(SCENE_TITLE);
	label.text = "Personagem: %s \n" % [monsterPlayedName]
	label.text += "Inimigos mortos: %d \n" % [enemiesKilled]
	label.text += "Turnos sobrevividos: %d \n" % [stagesSurvived]
	label.text += "PONTOS TOTAIS: %d \n" % [pointsEarned]

func fadeIn():
	score.create_tween().tween_property(score, "modulate", Color.WHITE, 2);

func _on_menu_button_pressed():
	Global.transitionTo("mainMenu")
