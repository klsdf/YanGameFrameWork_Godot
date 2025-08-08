class_name DialogSystem
extends Node

@onready var dialog_label: Label = $对话框
@onready var tachie : TextureRect = $立绘



func speak(content: String):
    dialog_label.text = content

