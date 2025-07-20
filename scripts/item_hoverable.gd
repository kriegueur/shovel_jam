extends Control

@export var item_resource : Item

@onready var icon_display: TextureRect = $IconDisplay
@onready var info_display: PanelContainer = $PanelContainer
@onready var name_indicator: Label = $PanelContainer/InfoDisplay/Name
@onready var description: Label = $PanelContainer/InfoDisplay/Description

# Called when the node enters the scene tree for the first time.
func init() -> void:
	icon_display.texture = item_resource.texture
	name_indicator.text = item_resource.name
	description.text = item_resource.description.replace('\\n', '\n')
	info_display.hide()
	icon_display.connect("mouse_entered", func():
		info_display.show()
	)
	icon_display.connect("mouse_exited", func():
		info_display.hide()
	)
	info_display.position = Vector2(0, -60)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
