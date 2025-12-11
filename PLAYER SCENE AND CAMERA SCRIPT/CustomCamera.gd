extends Camera3D
class_name CustomCamera ##Camara con limites y tweens

@export var objeto_referencia: Node3D = null
var offset_objeto: float = 0.0

@export var rango_x: Vector2 = Vector2(-64,64)
@export var rango_z: Vector2 = Vector2(-64,64)

##Posicion relativa de la camara con respecto al objeto de referencia
##X = distancia de camara a objeto, Y = Altura de la camara con respecto al objeto
@export var offset: Vector2 = Vector2(15,15)

func _ready():
	rotation_degrees.x = -40

func cambiar_referencia(nueva_referencia):
	objeto_referencia = nueva_referencia
	print('[REFERENCIA CAMARA CAMBIADA]', objeto_referencia)

func _process(delta: float) -> void:
	if objeto_referencia is Personaje:
		var pos_final: Vector3 = get_camera_pos_relative_to(objeto_referencia)
		pos_final.y -= offset_objeto
		
		global_position = pos_final

func get_camera_pos_relative_to(objeto)->Vector3:
	var new_position: Vector3 = get_camara_pos_relative_to_point(objeto.global_position)
	return new_position

func get_camara_pos_relative_to_point(point: Vector3):
	var new_position: Vector3 = Vector3.ZERO
	new_position.x = point.x
	new_position.y = point.y + offset.x
	new_position.z = point.z + offset.y
	
	# vectores de rango: x = minimo, y = maximo
	new_position.x = clamp(new_position.x, rango_x.x, rango_x.y)
	new_position.z = clamp(new_position.z, rango_z.x, rango_z.y)
	return new_position
