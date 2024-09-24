extends Camera2D

var dragging = false
var last_mouse_position = Vector2()
var zoom_step = 0.1  # Amount by which to zoom in/out
var min_zoom = Vector2(0.2, 0.2)  # Minimum zoom level
var max_zoom = Vector2(1.5, 1.5)  # Maximum zoom level

var enable_move = true
var enable_zoom = true

func _ready():
	zoom = Vector2(1, 1)  # Starting zoom level
	update_limits()
	

func _input(event):
	# Handle mouse button press
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if enable_move and event.is_pressed():
				dragging = true
				last_mouse_position = get_viewport().get_mouse_position()  # Use relative mouse position
				print("Dragging started at:", last_mouse_position)
			else:
				dragging = false
				print("Dragging stopped.")

		# Handle mouse wheel zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

	# Handle mouse movement when dragging
	if dragging and event is InputEventMouseMotion:
		var current_mouse_position = get_viewport().get_mouse_position()  # Use relative mouse position
		var delta = (current_mouse_position - last_mouse_position) / zoom.x  # Adjust for zoom level
		global_position -= delta  # Move the camera by the relative motion of the mouse
		last_mouse_position = current_mouse_position

		print("Mouse delta:", delta)
		print("Camera global_position after dragging:", global_position)
		clamp_position()  # Ensure the camera stays within limits
		

func zoom_in():
	if enable_zoom:
		zoom += Vector2(zoom_step, zoom_step)  # Decrease zoom for zooming in
		zoom = clamp(zoom, min_zoom, max_zoom)  # Clamp zoom level to avoid over-zooming
		#print("Zoomed in. New zoom level:", zoom)
		update_limits()
		clamp_position()

func zoom_out():
	if enable_zoom:
		zoom -= Vector2(zoom_step, zoom_step)  # Increase zoom for zooming out
		zoom = clamp(zoom, min_zoom, max_zoom)  # Clamp zoom level to avoid under-zooming
		#print("Zoomed out. New zoom level:", zoom)
		update_limits()
		clamp_position()
	

func update_limits():
	# Recalculate the camera limits when the zoom changes
	var background = $"/root/Playground/Background"
	var background_size = background.texture.get_size() * background.scale
	var background_center = background.global_position
	var screen_size = get_viewport_rect().size / zoom
	
	limit_left = background_center.x - (background_size.x / 2) - (screen_size.x / 2)
	limit_right = background_center.x + (background_size.x / 2) + (screen_size.x / 2)
	limit_top = background_center.y - (background_size.y / 2) - (screen_size.y / 2)
	limit_bottom = background_center.y + (background_size.y / 2) + (screen_size.y / 2)

	print("Limits updated - Left: ", limit_left, ", Top: ", limit_top, ", Right: ", limit_right, ", Bottom: ", limit_bottom, ", zoom: ", str(zoom))
	

func clamp_position():
	# Clamp the camera position based on the calculated limits
	global_position.x = clamp(global_position.x, limit_left, limit_right)
	global_position.y = clamp(global_position.y, limit_top, limit_bottom)
	print("Camera position clamped to:", global_position)
