extends Control

@export var background_images: Array[Texture2D] = []

@onready var bg_texture_rect: TextureRect = $Bg
# MUDANÇA AQUI: Trocamos $ por % para achar o nó em qualquer lugar da cena
@onready var fade_rect: ColorRect = $FadeRect 

var is_transitioning: bool = false

func _ready() -> void:
	if fade_rect:
		# Começa o jogo 100% preto
		fade_rect.visible = true
		fade_rect.modulate.a = 1.0
		fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Revela o menu (Fade-in)
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8)
		# Só libera os botões quando terminar de clarear
		tween.tween_callback(func(): fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE)

	if background_images.size() > 0:
		var random_bg = background_images.pick_random()
		bg_texture_rect.texture = random_bg

func _on_start_btn_pressed() -> void:
	if is_transitioning: return
	is_transitioning = true
	
	if fade_rect:
		# Bloqueia cliques repetidos cobrindo a tela
		fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var tween = create_tween()
		# Força a opacidade a voltar para 1.0 (Preto total) em 0.8 segundos
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
		
		# Comando mágico: o código vai pausar AQUI até o retângulo ficar totalmente preto
		await tween.finished
	
	# Só agora, com tudo escuro, a cena é trocada de forma invisível para o jogador
	get_tree().change_scene_to_file("res://game/cutscenes/CutsceneManager.tscn")
	if is_transitioning: return
	is_transitioning = true
	
	if fade_rect:
		fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		
		# Faz a tela escurecer suavemente (Fade-out)
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)
		
		# Só muda de cena quando o Tween terminar 100%
		tween.tween_callback(func(): 
			get_tree().change_scene_to_file("res://game/cutscenes/CutsceneManager.tscn")
		)
	
	get_tree().change_scene_to_file("res://game/cutscenes/CutsceneManager.tscn")

func _on_credits_btn_pressed() -> void:
	if is_transitioning: return
	get_tree().change_scene_to_file("res://game/title_screen/credits/credits_screen.tscn")

func _on_quit_btn_pressed() -> void:
	if is_transitioning: return
	get_tree().quit()
