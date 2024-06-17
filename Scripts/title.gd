extends Control

var titleStep = 0;

## Caso demore a conectar, o jogador será informado que pode atravessar o bloqueio.
var waitedTooLong: bool = false;

## Controla o estado das opções
@onready var infoLabel: Label = $Cover/InfoLabel
@onready var menuButtons = $Menu/MenuButtons
@onready var options = $Menu/Options

# Referências dos modelos 3D:
@onready var models = %Models.get_children()

# Caso precise
enum STEPS {
	CONNECTING,
	MENU,
	OPTIONS
}

func _ready():
	AudioManager.playBGM("title");
	setInitialConfig();
	focusFirstButton();


## Função para focar o primeiro botão de acordo com a visibilidade das seções do menu
func focusFirstButton():
	var _firstButton: Button;
	if %Menu/MenuButtons.visible:
		_firstButton = %Menu/MenuButtons.get_child(0);
	elif %Menu/Options.visible:
		_firstButton = %Menu/Options/OptionsButtons.get_child(0);
	print("[TITLE.focusFirstButton] - Focando: ", _firstButton.text);
	_firstButton.grab_focus.call_deferred();

func _process(delta):
	animateModels();
	manageHeaderText();
	
	match titleStep:
		STEPS.CONNECTING:
			if Connection.connected:
				%Menu.visible = true;
				
				await get_tree().create_timer(2).timeout;
				titleStep = STEPS.MENU;
				#Global.transitionTo("characterSelect");
			else:
				
				if waitedTooLong:
					pass
					#infoLabel.text += "\nAperte ESC para iniciar de qualquer forma."
				
				# DEBUG: Atravessar bloqueio. TODO: Retirar.
				if Input.is_action_just_pressed("ui_cancel"):
					menuButtons.get_node("StartButton").disabled = false;
					#Global.transitionTo("characterSelect");
					
					%Menu.visible = true;
					titleStep = STEPS.MENU;

		 ## TODO: tirar caso seja desnecessario
		STEPS.MENU:
			pass
			#%Cover.visible = false;

func manageHeaderText():
	if Connection.connected:
		infoLabel.text = "Conexão com a câmera estabelecida!";
		menuButtons.get_node("StartButton").disabled = false;
	else:
		infoLabel.text = "Tentando conectar à câmera" + Global.getDotsString();

func setInitialConfig():
	%Cover.visible = true;
	changeOptionsVisibility(Color.TRANSPARENT);
	
	titleStep = STEPS.CONNECTING;
	await get_tree().create_timer(3).timeout;
	waitedTooLong = true;

func _on_start_button_pressed():
	Global.transitionTo("characterSelect");

func _on_options_button_pressed():
	titleStep = STEPS.OPTIONS;
	changeMenuButtonsVisibility(Color.TRANSPARENT);
	changeOptionsVisibility(Color.WHITE);
	focusFirstButton()

func _on_quit_button_pressed():
	get_tree().quit();

func changeOptionsVisibility(color: Color):
	if color == Color.WHITE:
		options.visible = true;
	
	await options.create_tween().tween_property(options, "modulate", color, .3).finished;
	options.visible = color == Color.WHITE;

## Controlar visibilidade do Menu
func changeMenuButtonsVisibility(color: Color):
	if color == Color.WHITE:
		%Logo.visible = true;
		menuButtons.visible = true;
		
	await %Logo.create_tween().tween_property(%Logo, "modulate", color, .3);
	await menuButtons.create_tween().tween_property(menuButtons, "modulate", color, .3);
	
	%Logo.visible = color == Color.WHITE;
	menuButtons.visible = color == Color.WHITE


func _on_return_button_pressed():
	titleStep = STEPS.MENU;
	changeMenuButtonsVisibility(Color.WHITE);
	changeOptionsVisibility(Color.TRANSPARENT);
	focusFirstButton()

## Animar modelos 3D:
func animateModels():
	for model in models:
		var _anim = model.get_node("AnimationPlayer") as AnimationPlayer;
		if _anim.has_animation("Idle"):
			if model.name == "Crab":
				_anim.play("Dance");
			elif model.name == "Chicken":
				_anim.play("Jump");
			else:
				_anim.play("Idle");
		else:
			_anim.play("Flying");
			
# Método chamado sempre que uma entrada é recebida
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			focusFirstButton()

