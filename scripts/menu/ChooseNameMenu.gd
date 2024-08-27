extends Node2D

onready var lineEdit = get_node("TextContainer/HBoxContainer/LineEdit")
onready var caret = get_node("TextContainer/HBoxContainer/Caret")

var lastTick: float = 0.0
var caretOn: bool = true

func _ready():
	set_process(false)

func open():
	visible = true
	lineEdit.grab_focus()
	set_process(true)

func close():
	MasterInput.setMaster(Ref.game)
	visible = false
	Ref.currentLevel.visible = true
	Ref.ui.visible = true
	Ref.game.startGame()
	queue_free()

func _process(delta):
	lastTick += delta
	if lastTick >= 0.5:
		lastTick -= 0.5
		if lineEdit.text.length() < 12:
			if caretOn:
				caret.modulate.a = 0.0
				caretOn = false
			else:
				caret.modulate.a = 1.0
				caretOn = true
		else:
			caret.modulate.a = 0.0
			caretOn = false


func _on_LineEdit_text_entered(new_text):
	if lineEdit.text.length() == 0:
		return
	else:
		Ref.character.stats.setName(lineEdit.text)
		close()
