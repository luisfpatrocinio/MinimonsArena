extends Node3D

class_name Chest

const itemPackage = preload("res://Scenes/item.tscn")

var itemRes: ItemRes;

func _ready():
	pass

func setItemRes(res: ItemRes):
	itemRes = res;

## O baú instancia um item quando o player colide e aplica uma força
func _on_body_entered(body):
	if body is Monster:
		print_rich("[color=green]Pinto pegou ")
		
		if !itemRes:
			print_rich("[color=red]Baú: Nenhuma resource definida");
			return;
		
		var _playerPos = Global.monsterNode.global_position;
		
		var _item: Item = itemPackage.instantiate();
		_item.setItemRes(itemRes) 
		_item.global_position = Vector3(
			global_position.x,
			global_position.y + 2,
			global_position.z
		)
		#_item.global_position = global_position;
		get_parent().add_child(_item);
		_item.applyForce();
