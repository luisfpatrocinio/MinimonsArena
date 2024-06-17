extends Node
class_name Game

## Classe responsável por gerenciar as regras do jogo.

enum STAGES {PREPARATION, GAME}
var stage: int = STAGES.PREPARATION;
@onready var stageLabel: Label = null;

func _ready():
	Global.interfaceNode.setStageLabel(getActualStageString());
	
func _process(delta):
	if Global.levelNode == null:
		return;
	
	match stage:
		STAGES.PREPARATION:
			if Input.is_action_just_pressed("ui_accept"):
				stage = STAGES.GAME;
				Global.levelNode.generateEntities();
				
				Global.interfaceNode.setStageLabel(getActualStageString());
		STAGES.GAME:
			if Input.is_action_just_pressed("ui_cancel"):
				stage = STAGES.PREPARATION;
				Global.levelNode.startPreparation();
				# TODO: Limpar entidades de itens e demais coletáveis.
				
				Global.interfaceNode.setStageLabel(getActualStageString());

func getActualStageString() -> String:
	return "Etapa de Preparação" if stage == STAGES.PREPARATION else "Etapa de Batalha";
