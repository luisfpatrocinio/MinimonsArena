extends Node
class_name Game

## A classe Game coordena a lógica principal do jogo, incluindo a inicialização do Level, controle 
## de fluxo de jogo, e gerenciamento de estados. Este script é essencial para a execução e integração 
## de todos os componentes. Ele gerencia as etapas do jogo, alternando entre preparação, jogo e 
## vitória de nível, além de responder a entradas do jogador para iniciar o jogo, pausar ou retornar 
## à tela de título. A classe também é responsável por atualizar a interface do usuário com o estado 
## atual do jogo e iniciar entidades durante a fase de preparação.

enum STAGES {PREPARATION, GAME, LEVELWIN}
var stage: int = STAGES.PREPARATION;
@onready var stageLabel: Label = null;
var paused = false;

func _ready():
	Global.interfaceNode.setStageLabel(getActualStageString());
	
func _process(delta):
	if Global.levelNode == null:
		return;
	
	match stage:
		STAGES.PREPARATION:
			if !paused:
				if Input.is_action_just_pressed("ui_accept"):
					stage = STAGES.GAME;
					Global.levelNode.generateEntities();
					
					Global.interfaceNode.setStageLabel(getActualStageString());
		STAGES.GAME:
			# Verificar se existem inimigos vivos:
			if Global.levelNode.enemiesManager.get_child_count() <= 0:
				winThisLevel();
			
			if Input.is_action_just_pressed("ui_cancel"):
				stage = STAGES.PREPARATION;
				Global.levelNode.startPreparation();
				# TODO: Limpar entidades de itens e demais coletáveis.
	
	# Retornar para tela de título. @TODO: Substituir por pause e não restringir apenas a etapa de preparação.
	if Input.is_action_just_pressed("ui_cancel"):
		pause();

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

## Pausa ou despausa o jogo.
func pause() -> void:
	paused = !paused;
	if paused:
		Global.interfaceNode.pauseNode.get_node("VBoxContainer").get_node("PauseResumeButton").grab_focus.call_deferred();
	get_tree().paused = paused;	
