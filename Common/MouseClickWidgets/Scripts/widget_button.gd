extends ClickableItem
class_name WidgetButton

var pressed = false

func _clicked() -> void :
    pressed = not pressed

    if pressed:
        $TextureRect.modulate = Color.DARK_GRAY
    else:
        $TextureRect.modulate = Color.WHITE
