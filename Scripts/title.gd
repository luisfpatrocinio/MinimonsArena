extends Control

var titleStep = 0;

## Caso demore a conectar, o jogador será informado que pode atravessar o bloqueio.
var waitedTooLong: bool = false;

## Controla o estado das opções
@onready var infoLabel: Label = $Cover/InfoLabel
@onready var menuButtons = $Menu/MenuButtons
@onready var options = $Menu/Options
@onready var views: Array = [];

# Referências dos modelos 3D:
@onready var models = %Models.get_children()

# Referência da câmera
@onready var camera = %MainMenuPreview/Camera as Camera3D;

# Variável para gerenciar animações iniciais.
var startingProgress: float = 0.0;

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
	
	var _camInitialPos = camera.position;
	
	views = [menuButtons, options, $Menu/Credits];

	await camera.create_tween().tween_property(camera, "position", _camInitialPos.lerp(Vector3(-10, 0, -5), 0.069), 20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).finished;


## Função para focar o primeiro botão de acordo com a visibilidade das seções do menu
func focusFirstButton():
	var _firstButton: Control;
	if %Menu/MenuButtons.visible:
		_firstButton = %Menu/MenuButtons.get_child(0);
	elif %Menu/Options.visible:
		_firstButton = %Menu/Options/OptionsButtons.get_child(0);
	print("[TITLE.focusFirstButton] - Focando: ", _firstButton);
	
	if _firstButton is MenuBar:
		pass
		#_firstButton = _firstButton.get_child(0);
	
	if _firstButton != null:
		_firstButton.grab_focus.call_deferred();


func _process(delta):
	animateModels();
	manageHeaderText();
	manageCamera();
	
	menuButtons.get_node("StartButton").disabled = !Connection.connected;
	
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

func manageCamera():
	camera.look_at(Vector3(-2, 1, 0))
	pass
	#camera.translate(Vector3.BACK * (1.0 - startingProgress));

func manageHeaderText():
	if Connection.connected:
		infoLabel.text = "Conexão com a câmera estabelecida!";
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
	changeViewVisibility("Options");

## Ao pressionar o botão de sair do jogo.
func _on_quit_button_pressed():
	get_tree().quit();
	
func _on_credits_button_pressed():
	titleStep = STEPS.OPTIONS;
	changeViewVisibility("Credits");
	pass
	#Visibilidade do Menu de Créditos
	

func changeViewVisibility(viewName: String) -> void:
	for view in views:
		var _viewName = view.name;
		view.visible = false;
	
	for view in views:
		var _viewName = view.name;		
		if _viewName == viewName:
			view.visible = true;
			focusFirstButton();
			
		var _color = Color(1.0, 1.0, 1.0, float(view.visible));
		await view.create_tween().tween_property(view, "modulate", _color, .3).finished;
	

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
	changeViewVisibility("MenuButtons");
	#changeMenuButtonsVisibility(Color.WHITE);
	#changeOptionsVisibility(Color.TRANSPARENT);
	#focusFirstButton()

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

func _on_credits_return_button_pressed():
	titleStep = STEPS.MENU;
	changeViewVisibility("MenuButtons");
	#changeMenuButtonsVisibility(Color.WHITE);
	#changeOptionsVisibility(Color.TRANSPARENT);
	#focusFirstButton()
