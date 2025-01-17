extends Node2D

const MERCHANT_TYPE = 0

onready var bodySprite = get_node("BodySprite")

export (int, "Merchant") var type = 0

var pos = Vector2(0, 0)
var spokeWelcome: bool = false
var spokeIntro: bool = false

func welcome():
	if spokeWelcome:
		return
	say(quotes().WELCOME)
	spokeWelcome = true

func speak():
	if spokeIntro:
		say(Utils.chooseRandom(quotes().DIALOGUES))
	else:
		say(quotes().INTRO)
		spokeIntro = true

func say(msg: String):
	Ref.ui.write(quotes().NAME + ' says: "' + msg + '"')

func setPosition(newPos: Vector2):
	pos = newPos
	refreshMapPosition()

func refreshMapPosition():
	position = 9 * pos

func quotes() -> Object:
	match type:
		MERCHANT_TYPE:
			return get_node("Merchant")
		_:
			return get_node("Merchant")
