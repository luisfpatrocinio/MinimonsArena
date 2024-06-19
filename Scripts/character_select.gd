extends Node3D

@onready var instructionLabel: Label3D = get_node("InstructionLabel");
@onready var characterNameLabel: Label3D = get_node("CharacterNameLabel");
var selected = 0;
@onready var characterNode = get_node("Character");
@onready var monsterKeys = Global.monsterDict.keys()
var selectedKey: String = "";
var detectedCharacters = [];
var modelProgress: float = 0.0;

func _ready():
	AudioManager.playBGM("characterSelect");
	pass
	#Global.insertTag.connect(changeCharacter)

func _process(delta):
	# Detectar qual player o jogador deseja.
	detectedCharacters = [];
	for i in Global.detectedTagsDict:
		if i != 0:
			var _charKey = Global.getEntityKeyById(i);
			detectedCharacters.append(_charKey)
	
	manageInstructions();
	
	# Aqui teremos detectedCharacters = ["cyclops"]
	changeCharacter();
	
	# Animar modelo
	animateModel();
		
	# Confirmar Personagem
	if Input.is_action_just_pressed("ui_accept"):
		Global.monsterKey = selectedKey;
		Global.transitionTo("gameLevel");
		
	# Cancelar
	elif Input.is_action_just_pressed("ui_cancel"):
		# TODO: Criar função de redefinir valores globais.
		Global.transitionTo("title");

func animateModel():
	var _ang = Time.get_ticks_msec() / 100.0;
	_ang = wrap(_ang, 0.0, 360.0)
	
	characterNode.rotation.y = sin(deg_to_rad(_ang)) * 0.5;
	
	if characterNode.get_child_count() > 1:
		var _model = characterNode.get_child(1)
		_model.rotation.y = lerp(_model.rotation.y, deg_to_rad(modelProgress * 360.0), 0.169);
		_model.scale = Vector3(modelProgress, modelProgress, modelProgress);
		if _model != null:
			var _anim : AnimationPlayer = _model.get_node("AnimationPlayer");
			if _anim.has_animation("Dance"):
				_anim.play("Dance");
			else:
				_anim.play("Flying");
	else:
		characterNode.rotation.y += 0.02;

## Atribuir character
func changeCharacter():
	# Chave do monstro atual.
	if len(detectedCharacters) <= 0 or !checkOnlyOneChar():
		if characterNode.get_child_count() > 1:
			deleteCharacterNodeModel()	# Deletar modelo atual caso haja.
		return
	
	var _selectedMonsterKey = detectedCharacters[0];
	# Modelo do monstro atual.
	var _monsterDict = Global.monsterDict.get(_selectedMonsterKey);
	if _monsterDict == null: return
	var _monsterModel = _monsterDict.get("model") as PackedScene;
	# Caso não tenha modelo 3D
	if characterNode.get_child_count() <= 1:
		print("Modelo 3D atribuído.")
		var _model = _monsterModel.instantiate();
		characterNode.add_child(_model);
		selectedKey = _selectedMonsterKey;
		Global.selectedCharacters.append(selectedKey);
		modelProgress = 0.0;
	else:
		# Conferindo se o modelo atual é o modelo correto.
		var _actualModel = characterNode.get_child(1);
		if len(Global.selectedCharacters) > 0 and Global.selectedCharacters[0] != detectedCharacters[0]:
			_actualModel.queue_free();	# Deletar modelo atual.
			var _model = _monsterModel.instantiate();
			characterNode.add_child(_model);
			Global.selectedCharacters = [];
			Global.selectedCharacters.append(detectedCharacters[0])
			print_rich("[b][CHARACTER][/b] - Player definido: ", detectedCharacters[0])
			
func checkOnlyOneChar() -> bool:
	return len(detectedCharacters) == 1
	
func manageInstructions():
	var _instructionY: float = 0.0;
	var _characterY: float = -2.0;
	
	# Tabuleiro não encontrado
	if !Global.checkHasBoard():
		instructionLabel.text = tr("SEARCHING_BOARD") + Global.getDotsString();
		characterNameLabel.text = "";
		_instructionY = 2.0;
		_characterY = -1.0;
	else:	
		# Verificar se há personagens.
		if len(detectedCharacters) > 0:
			# Caso só haja uma tag.
			if checkOnlyOneChar():
				var char: String = detectedCharacters[0];
				var _isValid: bool = Global.monsterDict.has(char);
				
				var _monsterName = "ERROR" if !_isValid else Global.monsterDict.get(char).name;
				characterNameLabel.text = _monsterName;
				instructionLabel.text = tr("PRESS_START") if _isValid else tr("ONLY_ONE_MINIMON_CARD")
				
				if _isValid:
					_instructionY = 2.0;
					_characterY = -1.0;
				else:
					deleteCharacterNodeModel();
					_instructionY = 1.0;
					_characterY = -1.0;
			else:
				deleteCharacterNodeModel()	# Deletar modelo atual caso haja.
				instructionLabel.text = tr("ONLY_ONE_CARD")
				characterNameLabel.text= "";
				_instructionY = 0.0;
				_characterY = -2.0;
		else:
			instructionLabel.text = tr("PLACE_A_MINIMON_CARD")
			characterNameLabel.text = "";
	
	instructionLabel.position.y = lerp(instructionLabel.position.y, _instructionY, 0.169);
	if characterNode.get_child_count() > 1:
		var _model = characterNode.get_child(1);
		modelProgress = move_toward(modelProgress, 1.0, 0.035);		
		_model.position.y = -1.0 * modelProgress**2 + modelProgress + 0.0
	characterNode.position.y = lerp(characterNode.position.y, _characterY, 0.169);
	
func deleteCharacterNodeModel() -> void:
	if characterNode.get_child_count() > 1:
		var _actualModel = characterNode.get_child(1);
		if _actualModel != null:
			print("Deletando modelo.");
			_actualModel.queue_free();	
