extends CanvasLayer
class_name Interface

var showingLabel: bool = false;
@onready var stageLabel: Label = get_node("StageLabel");

var scoreDraw: int = 0;
@onready var scoreLabel: Label = get_node("HeaderBar/ScoreLabel");
var healthPoints: int = 0;
@onready var healthLabel: Label = get_node("HeaderBar/HealthLabel");
var progress: float = 0.0;

func _ready():
	Global.interfaceNode = self;

func setStageLabel(text):
	stageLabel.text = text;
	var _viewHeight = get_viewport().get_visible_rect().size.y
	
	showingLabel = true;
	
	var _tween1 = stageLabel.create_tween();
	_tween1.set_trans(Tween.TRANS_CUBIC);	
	_tween1.tween_property(stageLabel, "position", Vector2(0, _viewHeight/2), .25);
	_tween1.set_ease(Tween.EASE_OUT);
	await _tween1.finished;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	await get_tree().create_timer(1).timeout;
	
	var _tween2 = stageLabel.create_tween();
	_tween2.set_trans(Tween.TRANS_CUBIC);	
	_tween2.tween_property(stageLabel, "position", Vector2(0, 72), .369);
	_tween2.set_ease(Tween.EASE_OUT);
	await _tween2.finished;
	
	showingLabel = false;
	

## Exibir alerta na parte de baixo, ajustando a opacidade caso seja um texto novo.
func showWarning(text: String):
	var _warningLabel = get_node("WarningLabel") as Label;
	if _warningLabel.text.rstrip(".") != text.rstrip("."):
		progress = 0.0;
		_warningLabel.modulate.a = 0.0;
	
	if _warningLabel.text != text:
		_warningLabel.text = text;
	

func _process(delta):
	# Update progress value
	progress = move_toward(progress, 1.0, 0.025);
	
	# Get player health points
	var _hp = 3;	# TODO: Obter a partir do jogador.
	healthLabel.text = "HP: " + str(_hp);
	
	# Update Score
	var _sp = 5 + abs(Global.score - scoreDraw) / 10;
	scoreDraw = move_toward(scoreDraw, Global.score, _sp)
	scoreLabel.text = tr("SCORE") + ": " + str(scoreDraw);
	
	var _rect = get_node("ColorRect") as ColorRect;
	var _warningLabel = get_node("WarningLabel") as Label;
	_warningLabel.modulate.a = progress;
	var _rectAlpha = 0.00;
	
	# Alertar se faltar tabuleiro
	if !Global.checkHasBoard():
		showWarning("Localizando tabuleiro" + Global.getDotsString());
		_rectAlpha = 0.50;		
	elif !Global.checkHasPlayer():
		if len(Global.selectedCharacters) <= 0:
			return;
		
		var _playerName = Global.monsterDict.get(Global.selectedCharacters[0]).get("name", "NOME NÃO ENCONTRADO");
		showWarning("Coloque a carta do herói %s" % [_playerName] + Global.getDotsString());
		_rectAlpha = 0.50;		
	else:
		showWarning("");
		_rectAlpha = 0.00;		
	
	_rectAlpha = 0.50 if showingLabel else _rectAlpha;
	
	if Global.debugMode:
		_rectAlpha = 0.00;
		showWarning("Debug Mode");
	
	_rect.color.a = lerp(_rect.color.a, _rectAlpha, 0.169);
	
