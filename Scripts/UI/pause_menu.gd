extends Control

@onready var panelOptions: Panel = $PanelOptions
@onready var menuButton: TextureButton = $MenuButton

func _ready():
	panelOptions.modulate = Color.TRANSPARENT;

func setPanelColor(color: Color):
	panelOptions.create_tween().tween_property(panelOptions, "modulate", color, .5);

func _on_menu_button_pressed():
	setPanelColor(Color.WHITE)
	menuButton.visible = false;

func _on_resume_button_pressed():
	setPanelColor(Color.TRANSPARENT)
	menuButton.visible = true;
