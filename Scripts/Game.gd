extends Node
class_name Game

## Classe responsável por gerenciar as regras do jogo.

enum STAGES {PREPARATION, GAME}
var stage: int = STAGES.PREPARATION;
@onready var stageLabel: Label = null;

func _ready():
	pass
	
func _process(delta):
	if Global.levelNode != null:
		stageLabel = Global.levelNode.interfaceNode.get_node("StageLabel");
		stageLabel.text = "Preparação" if stage == STAGES.PREPARATION else "Batalha";
	
	match stage:
		STAGES.PREPARATION:
			if Input.is_action_just_pressed("ui_accept"):
				stage = STAGES.GAME;
				Global.levelNode.generateEntities();
		STAGES.GAME:
			if Input.is_action_just_pressed("ui_accept"):
				stage = STAGES.PREPARATION;
				Global.levelNode.startPreparation();
