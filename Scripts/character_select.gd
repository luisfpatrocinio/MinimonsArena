extends Node3D

@onready var instructionLabel: Label3D = get_node("InstructionLabel");
@onready var characterNameLabel: Label3D = get_node("CharacterNameLabel");
var selected = 0;
@onready var characterNode = get_node("Character");
@onready var monsterKeys = Global.monsterDict.keys()
var selectedKey: String = "";
var detectedCharacters = []

func _ready():
	pass
	#Global.insertTag.connect(changeCharacter)

func _process(delta):
	# Detectar qual player o jogador deseja.
	detectedCharacters = [];
	for i in Global.detectedTagsDict:
		if i != 0:
			var _charKey = Global.getEntityKeyById(i);
			detectedCharacters.append(_charKey)
	
	if len(detectedCharacters) > 0:
		var char = detectedCharacters[0];
		var _monsterName = Global.monsterDict.get(char).name;
		characterNameLabel.text = _monsterName;
		instructionLabel.text = "Aperte START para começar!"
	else:
		instructionLabel.text = "Posicione seu herói no tabuleiro: "
		characterNameLabel.text = "";
	
	# Aqui teremos detectedCharacters = ["cyclops"]
	
	changeCharacter();
	
	# Animar modelo
	animateModel();
		
	# Confirmar Personagem
	if Input.is_action_just_pressed("ui_accept"):
		Global.monsterKey = selectedKey;
		Global.transitionTo("gameLevel");

func animateModel():
	characterNode.rotation.y += 0.02;
	if characterNode.get_child_count() > 0:
		var _model = characterNode.get_child(0)
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
	if len(detectedCharacters) <= 0:
		if characterNode.get_child_count() > 0:
			var _actualModel = characterNode.get_child(0);
			if _actualModel != null:
				print("Deletando?????")
				_actualModel.queue_free();	# Deletar modelo atual caso haja.
		return
	
	var _selectedMonsterKey = detectedCharacters[0];
	# Modelo do monstro atual.
	var _monsterModel = Global.monsterDict.get(_selectedMonsterKey).get("model") as PackedScene;
	# Caso não tenha modelo 3D
	if characterNode.get_child_count() <= 0:
		print("Modelo 3D atribuído.")
		var _model = _monsterModel.instantiate();
		characterNode.add_child(_model);
		selectedKey = _selectedMonsterKey;
		Global.selectedCharacters.append(selectedKey)
	else:
		# Conferindo se o modelo atual é o modelo correto.
		var _actualModel = characterNode.get_child(0);
		if len(Global.selectedCharacters) > 0 and Global.selectedCharacters[0] != detectedCharacters[0]:
			_actualModel.queue_free();	# Deletar modelo atual.
			var _model = _monsterModel.instantiate();
			characterNode.add_child(_model);
			Global.selectedCharacters = [];
			Global.selectedCharacters.append(detectedCharacters[0])
			print_rich("[b][CHARACTER][/b] - Player definido: ", detectedCharacters[0])
