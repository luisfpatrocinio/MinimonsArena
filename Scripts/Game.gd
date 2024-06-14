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
			if Input.is_action_just_pressed("ui_cancel"):
				stage = STAGES.PREPARATION;
				Global.levelNode.startPreparation();

	var _interface = Global.levelNode.interfaceNode
	var _rect = _interface.get_node("ColorRect") as ColorRect;
	var _warningLabel = _interface.get_node("WarningLabel") as Label;
	
	# Alertar se faltar tabuleiro
	if !Global.checkHasBoard():
		_warningLabel.text = "Localizando tabuleiro";
		var _pointsCount = (Time.get_ticks_msec() / 500) % 4;
		_warningLabel.text += str(".").repeat(_pointsCount);
		_rect.color.a = lerp(_rect.color.a, 0.50, 0.169);
	elif !Global.checkHasPlayer():
		var _playerName = Global.monsterDict.get(Global.selectedCharacters[0]).get("name", "NOME NÃO ENCONTRADO");
		_warningLabel.text = "Coloque a carta do herói %s" % [_playerName];
		var _pointsCount = (Time.get_ticks_msec() / 500) % 4;
		_warningLabel.text += str(".").repeat(_pointsCount);
		_rect.color.a = lerp(_rect.color.a, 0.50, 0.169);
		
	else:
		_warningLabel.text = "";
		_rect.color.a = lerp(_rect.color.a, 0.00, 0.169);
