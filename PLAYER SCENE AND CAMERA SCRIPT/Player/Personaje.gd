extends CharacterBody3D

class_name Personaje

@onready var animated_sprite_3d : AnimatedSprite3D = $AnimatedSprite3D
@onready var collision_shape_3d = $CollisionShape3D
#@onready var camera : Camera3D = get_viewport().get_camera_3d()

var billboard_autoscaling : bool
var direcciones = {"IZQUIERDA":Vector3(-1,0,0), "DERECHA":Vector3(1,0,0), "ARRIBA":Vector3(0,0,-1), "ABAJO":Vector3(0,0,1)} 

#func _physics_process(delta):
	#if animated_sprite_3d.billboard == BaseMaterial3D.BILLBOARD_ENABLED:
		#collision_shape_3d.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-30))
	## Calcula la dirección desde el sprite hacia la cámara y normalízala
	#var direction_to_camera: Vector3 = camera.global_transform.origin - global_transform.origin
	#direction_to_camera = direction_to_camera.normalized()
#
	## Ajusta la rotación del nodo padre de CollisionShape3D para alinear con la dirección
	#var target_rotation: Vector3 = direction_to_camera.cross(Vector3.UP).normalized()
	#var angle: float = acos(direction_to_camera.dot(Vector3.UP))
	#collision_shape_3d.get_parent().rotate(target_rotation, angle)

func set_billboard_mode(enabled: bool):
	var billboard_mode: BaseMaterial3D.BillboardMode = BaseMaterial3D.BillboardMode.BILLBOARD_ENABLED
	if !enabled:
		billboard_mode = BaseMaterial3D.BillboardMode.BILLBOARD_DISABLED
	
	animated_sprite_3d.billboard = billboard_mode

#Almacena las velocidades para cada accion
const VELOCIDAD_EVENTO = {"corriendo":4, "caminando": 2} 

func mover(direccion_parametro:String, distancia: float, accion: String, parallel: bool= false):
	var direccion = direcciones[direccion_parametro]
	var final_position = position + direccion * distancia
	var character_movement = get_tree().create_tween().set_parallel(parallel)
	var velocidad: float = VELOCIDAD_EVENTO[accion]
	character_movement.tween_property(self, "position:x", final_position.x, distancia/velocidad)
	character_movement.tween_property(self, "position:z", final_position.z, distancia/velocidad)
	return await character_movement.finished
		
