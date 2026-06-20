extends Node3D

@export var rope: Node3D 
@export var rope_mesh: MeshInstance3D 
@export var rope_visual_end: Marker3D 
@export var hook_end: Node3D
@export var time_to_reach_hook_mult: float = 5.0

var distance_to_go: float

func _ready() -> void:
	# é desativado o shader de distorção no material da corda após o impacto inicial
	if rope_mesh.material_override:
		rope_mesh.material_override.set_shader_parameter("active", 1.0)
		await get_tree().create_timer(0.15).timeout
		if rope_mesh.material_override:
			rope_mesh.material_override.set_shader_parameter("active", 0.0)

func extend_from_to(source_position: Vector3, target_position: Vector3, target_normal: Vector3, delta: float) -> void:
	# é definida a posição da ponta do gancho no mundo
	hook_end.global_position = target_position
	
	# é executada a rotação direcional da ponta do gancho em relação ao jogador
	align_hook_end(target_normal)
	
	# é atualizada a origem do sistema de corda
	global_position = source_position
	
	# é calculada a distância física do cabo
	var visual_target_position: Vector3 = get_visual_target(target_position)
	var distance_to_target: float = global_position.distance_to(visual_target_position)
	
	distance_to_go = lerpf(distance_to_go, distance_to_target, delta * time_to_reach_hook_mult)
	
	# é escalada e posicionada a geometria cilíndrica para simular tensão
	if rope_mesh and rope_mesh.mesh:
		rope_mesh.mesh.height = distance_to_go
		rope_mesh.position.z = -distance_to_go / 2.0
	
	# é apontado o contêiner da corda para o alvo visual
	if not global_position.is_equal_approx(visual_target_position):
		var up_vector: Vector3 = Vector3.UP
		if abs(global_position.direction_to(visual_target_position).y) > 0.99:
			up_vector = Vector3.RIGHT
		rope.look_at(visual_target_position, up_vector)

func align_hook_end(target_normal: Vector3) -> void:
	# é evitada a falha matemática caso o vetor normal seja nulo
	if target_normal == Vector3.ZERO:
		return
		
	# é definido o ponto reverso para garantir que as lâminas do gancho apontem para longe do jogador
	var look_target: Vector3 = hook_end.global_position - target_normal
	
	# é aplicada a proteção de vetor auxiliar para impedir travamento de gimbal em tiros perfeitamente verticais
	var up_vector: Vector3 = Vector3.UP
	if abs(target_normal.y) > 0.99:
		up_vector = Vector3.RIGHT
		
	# é aplicada a rotação final no objeto da ponta
	hook_end.look_at(look_target, up_vector)

func get_visual_target(default_value: Vector3) -> Vector3:
	# é retornado o marcador visual designado para manter a integridade gráfica caso exista
	if rope_visual_end:
		return rope_visual_end.global_position
		
	return default_value
