extends Node
class_name Game

## Classe responsável por gerenciar as regras do jogo.

enum STAGES {PREPARATION, GAME, LEVELWIN}
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
				
			# Retornar para tela de título. @TODO: Substituir por pause e não restringir apenas a etapa de preparação.
			if Input.is_action_just_pressed("ui_cancel"):
				Global.transitionTo("title");
		STAGES.GAME:
			# Verificar se existem inimigos vivos:
			if Global.levelNode.enemiesManager.get_child_count() <= 0:
				winThisLevel();
			
			if Input.is_action_just_pressed("ui_cancel"):
				stage = STAGES.PREPARATION;
				Global.levelNode.startPreparation();
				# TODO: Limpar entidades de itens e demais coletáveis.
				
				

func getActualStageString() -> String:
	return "Etapa de Preparação" if stage == STAGES.PREPARATION else "Etapa de Batalha";

func winThisLevel():
	stage = STAGES.LEVELWIN;
	var _players = Global.levelNode.charactersNode.get_children();
	for _player: Monster in _players:
		_player.dancing = true;
	
	await get_tree().create_timer(2).timeout;
	Global.levelNode.startPreparation();
	Global.interfaceNode.setStageLabel(getActualStageString());	
