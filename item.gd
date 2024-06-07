extends Entity

class_name Item;

var itemRes: ItemRes;

func _ready():
	pass 

## Só move o item se estiver fora do chão
func _physics_process(delta):
	super(delta);
	
	if not is_on_floor():
		move_and_slide();

## Escolhe uma direção aleatória e aplica uma "força"
func applyForce():
	var _dir: Vector3 = Vector3(
		randi_range(-1, 1),
		3,
		randi_range(-1, 1),
	)
	
	velocity = _dir * 2;

func setItemRes(res: ItemRes):
	itemRes = res;
	_setItemModel(res.modelPath);

## Apenas instamcia um model ao item
func _setItemModel(path: String):
	var _modelPackage = load(path);
	
	if !_modelPackage:
		print_rich("[Color=red]Item: Falha ao carregar o model de %s" % [itemRes.itemName]);
		
	var _model = _modelPackage.instantiate();
	add_child(_model);
