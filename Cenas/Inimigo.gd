extends CharacterBody3D

@export var velocidade = 3  #Velocidade do guarda
@export var pontos_patrulha : Array  #Lista dos pontos de patrulha
@export var tempo_pausa_inicial : float = 3.0  #Tempo de pausa em cada ponto de patrulha, visível no inspetor
@export var proximidade_para_capturar : float = 0.1  #Distância para capturar o personagem (quanto mais próximo, mais rápido ele será capturado)

var indice_ponto_atual = 0  #ponto atual na patrulha
var atingiu_ponto : bool = false  #flag para saber se atingiu o ponto de patrulha
var tempo_pausa : float = 0  

@onready var area_detecao := $Area3D  
var alvo_personagem : CharacterBody3D = null  #alvo (personagem) a ser perseguido

var GRAVITY = -30
var velocidade_movimento = 5

var patrulha_area : Node3D = null  #Variável para armazenar a instância da patrulha

func _ready():
	#Tornar os pontos de patrulha invisíveis em tempo de execução
	var pontos_nos = get_tree().get_nodes_in_group("pontos_patrulha")
	for ponto in pontos_nos:
		ponto.visible = false 

	#Adiciona os pontos de patrulha ao array
	pontos_patrulha.clear()  
	for ponto in pontos_nos:
		pontos_patrulha.append(ponto)
	if pontos_patrulha.is_empty():  
		print("Erro: Não foi possível encontrar pontos de patrulha.")
		return

	#Inicia o movimento para o primeiro ponto
	_mover_para_ponto(pontos_patrulha[indice_ponto_atual].global_transform.origin)

	#(verifica quando o personagem entra na área)
	area_detecao.body_entered.connect(Callable(self, "_on_body_entered"))
	area_detecao.body_exited.connect(Callable(self, "_on_body_exited"))

func _physics_process(delta: float) -> void:
	if alvo_personagem:
		_perseguir_personagem(delta)
	else:
		if tempo_pausa > 0:
			tempo_pausa -= delta
		else:
			if atingiu_ponto:
				#Se o guarda atingiu o ponto, escolhe o próximo ponto
				indice_ponto_atual = (indice_ponto_atual + 1) % pontos_patrulha.size()
				_mover_para_ponto(pontos_patrulha[indice_ponto_atual].global_transform.origin)
				atingiu_ponto = false  # Reseta a flag de atingir ponto
			else:
				#Move-se para o ponto de patrulha
				_mover_para_ponto(pontos_patrulha[indice_ponto_atual].global_transform.origin)

	#Aplica a gravidade e move o guarda
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

#para mover o guarda para o ponto
func _mover_para_ponto(ponto : Vector3) -> void:
	var direcao = (ponto - global_transform.origin).normalized()
	velocity.x = direcao.x * velocidade_movimento
	velocity.z = direcao.z * velocidade_movimento

	#Verifica se o guarda atingiu o ponto de patrulha
	if global_transform.origin.distance_to(ponto) < 1.0:
		atingiu_ponto = true  
		velocity.x = 0
		velocity.z = 0
		tempo_pausa = tempo_pausa_inicial 

#chamada quando um corpo entra na área de detecção
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  
		alvo_personagem = body  #Atribui o personagem como alvo
		#Pausa a patrulha, guarda agora segue o personagem
		atingiu_ponto = false
		tempo_pausa = 0 

#chamada quando um corpo sai da área de detecção
func _on_body_exited(body: Node) -> void:
	if body == alvo_personagem:
		alvo_personagem = null  #Limpa o alvo se o personagem sair da área
		# Retorna à patrulha quando o personagem sair da área de detecção
		atingiu_ponto = true
		tempo_pausa = 0  


func _perseguir_personagem(delta: float) -> void:
	if alvo_personagem:
		#Move diretamente para a posição do personagem
		var direcao = (alvo_personagem.global_transform.origin - global_transform.origin).normalized()

		#Aplique a movimentação do guarda em direção ao personagem
		velocity.x = direcao.x * velocidade_movimento
		velocity.z = direcao.z * velocidade_movimento

		#Garantir que o guarda continue se movendo até atingir o personagem
		if global_transform.origin.distance_to(alvo_personagem.global_transform.origin) < proximidade_para_capturar:

			velocity.x = 0
			velocity.z = 0
