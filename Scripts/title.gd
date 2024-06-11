extends Control

var titleStep = 0;

## Caso demore a conectar, o jogador será informado que pode atravessar o bloqueio.
var waitedTooLong: bool = false;

## Controla o estado das opções


@onready var infoLabel: Label = $Cover/InfoLabel
@onready var menuButtons = $Menu/MenuButtons
@onready var options = $Menu/Options

# Caso precise
enum STEPS {
	CONNECTING,
	MENU,
	OPTIONS
}

func _ready():
	setInitialConfig();

func _process(delta):
	match titleStep:
		STEPS.CONNECTING:
			# Desabilita o subviewport para não consumir muito processamento ( faça o teste no Debugger>visual profiler > start )
			%Menu.visible = false;
			
			var _pointsCount = (Time.get_ticks_msec() / 500) % 4;
			
			if Connection.connected:
				%Menu.visible = true;
				titleStep = STEPS.MENU;
				infoLabel.text = "Conexão com a câmera estabelecida!";
				await get_tree().create_timer(2).timeout;
				#Global.transitionTo("characterSelect");
			else:
				infoLabel.text = "Tentando conectar à câmera" + str(".").repeat(_pointsCount);
				
				if waitedTooLong:
					infoLabel.text += "\nAperte ESC para iniciar de qualquer forma."
				
				# DEBUG: Atravessar bloqueio. TODO: Retirar.
				if Input.is_action_just_pressed("ui_cancel"):
					#Global.transitionTo("characterSelect");
					
					%Menu.visible = true;
					titleStep = STEPS.MENU;

		 ## TODO: tirar caso seja desnecessario
		STEPS.MENU:
			%Cover.visible = false;

func setInitialConfig():
	%Cover.visible = true;
	%Menu.visible = false;
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

func _on_quit_button_pressed():
	get_tree().quit();

func changeOptionsVisibility(color: Color):
	if color == Color.WHITE:
		options.visible = true;
	
	await options.create_tween().tween_property(options, "modulate", color, .3).finished;
	options.visible = color == Color.WHITE;
	
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
