extends Control

@export var item_resource : Item

@onready var icon_display: TextureRect = $MainContainer/IconDisplay
@onready var info_display: VBoxContainer = $MainContainer/InfoDisplay
@onready var name_indicator: Label = $MainContainer/InfoDisplay/Name
@onready var description: Label = $MainContainer/InfoDisplay/Description

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	icon_display.texture = item_resource.texture
	name_indicator.text = item_resource.name
	description.text = item_resource.description
	info_display.hide()
	icon_display.connect("mouse_entered", func():
		info_display.show()
	)
	icon_display.connect("mouse_exited", func():
		info_display.hide()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
