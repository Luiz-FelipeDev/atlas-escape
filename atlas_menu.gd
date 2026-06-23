extends Control

@export_group("Configurações")
@export var lista_criaturas: Array[CreatureData]
@export var slot_prefab: PackedScene # Arraste aqui o 'AtlasSlot.tscn'
@export var photobooth_scene: PackedScene # Arraste aqui o seu 'Photobooth.tscn'

# Novas referências para as páginas divididas
# Certifique-se de que a estrutura na sua cena 2D tenha o HBoxContainer e as duas grades!
@onready var grade_esquerda: GridContainer = $HBoxContainer/GradeEsquerda
@onready var grade_direita: GridContainer = $HBoxContainer/GradeDireita

func _ready() -> void:
	generate_atlas()

func generate_atlas() -> void:
	# Instancia o gerador de fotos na árvore de forma invisível
	var photobooth = photobooth_scene.instantiate()
	add_child(photobooth)
	
	# Limpa ambas as grades antes de gerar os novos slots
	for child in grade_esquerda.get_children():
		child.queue_free()
	for child in grade_direita.get_children():
		child.queue_free()
		
	var contador: int = 0 # Rastreador para saber em qual posição estamos inserindo
		
	# Gera a foto e o slot para cada criatura configurada
	for creature in lista_criaturas:
		if creature.model_scene:
			# Aguarda o Photobooth gerar a textura
			var photo = await photobooth.take_snapshot(creature.model_scene, creature.isInverted)
			creature.snapshot_texture = photo
			
			# Cria o slot visual na interface
			var slot = slot_prefab.instantiate()
			
			# LÓGICA DE DISTRIBUIÇÃO DAS PÁGINAS (Layout 2x2 em cada folha):
			# Os primeiros 4 monstros (índices 0, 1, 2, 3) vão para a página esquerda
			if contador < 4:
				grade_esquerda.add_child(slot)
			# Os próximos 4 monstros (índices 4, 5, 6, 7) vão para a página direita
			elif contador < 8:
				grade_direita.add_child(slot)
			else:
				# Se o array tiver mais de 8 monstros, interrompe o loop por enquanto
				# para evitar que quebre o layout visual do livro aberto na tela.
				# No futuro, aqui faremos a paginação dinâmica!
				break
			
			# Configura as informações do monstro no slot inserido
			slot.setup(creature)
			contador += 1
			
	# Remove o photobooth pois as fotos já estão salvas na RAM
	photobooth.queue_free()
