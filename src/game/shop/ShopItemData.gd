class_name ShopItemData extends Resource

enum Type{
	COSTUME,
	LEVEL,
	UPGRADE
}

@export var itemId:String = ""
@export var price:int = 0
@export var color:Color = Color.RED
@export var description: String = ""
@export var type:Type = Type.COSTUME
@export var costumeSheet:SpriteFrames

@export var icon:Texture2D
@export var levelScn:PackedScene
