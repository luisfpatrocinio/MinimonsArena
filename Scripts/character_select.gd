extends Node3D

@onready var label: Label3D = get_node("Label3D");
var selected = 0;
@onready var characterNode = get_node("Character");
@onready var monsterKeys = Global.monsterDict.keys()
var selectedKey: String = "";

func _process(delta):
	# Detectar qual player o jogador deseja.
	label.text = "Posicione seu herói no tabuleiro:\n"
	
	var _detectedCharacters = []
	for i in Global.detectedTagsDict:
		if i != 0:
			_detectedCharacters.append(Global.getEntityKeyById(i))
			
	for char in _detectedCharacters:
		label.text += char + "\n"
	
	## Atribuir character
	# Chave do monstro atual.
	if len(_detectedCharacters) <= 0:
		return
		
	var _selectedMonsterKey = _detectedCharacters[0];
	# Modelo do monstro atual.
	var _monsterModel = Global.monsterDict.get(_selectedMonsterKey).get("model") as PackedScene;
	# Caso não tenha modelo 3D
	if characterNode.get_child_count() <= 0:
		print("Modelo 3D atribuído.")
		var _model = _monsterModel.instantiate();
		characterNode.add_child(_model);
		selectedKey = _selectedMonsterKey;
	else:
		# Conferindo se o modelo atual é o modelo correto.
		var _actualModel = characterNode.get_child(0);
		if monsterKeys[selected] != selectedKey:
			_actualModel.queue_free();	# Deletar modelo atual.
			var _model = _monsterModel.instantiate();
			characterNode.add_child(_model);
			selectedKey = _selectedMonsterKey;
			
	# Animar modelo
	if characterNode.get_child_count() >= 0:
		var _model = characterNode.get_child(0)
		if _model != null:
			var _anim : AnimationPlayer = _model.get_node("AnimationPlayer");
			if _anim.has_animation("Dance"):
				_anim.play("Dance");
			else:
				_anim.play("Flying");
			
		
	# Confirmar Personagem
	if Input.is_action_just_pressed("ui_accept"):
		Global.monsterKey = selectedKey;
		Global.transitionTo("gameLevel");
