extends GPUParticles2D
## GPUParticles2D 池化适配：ParticlePool.spawn() 时调 begin_play()
## texture 由代码注入（ParticleTextures 静态缓存），.tscn 里 texture 留空

@export var texture_kind: ParticleTextures.Kind = ParticleTextures.Kind.DISC


func _ready() -> void:
	if texture == null:
		texture = ParticleTextures.get_texture(texture_kind)


func begin_play() -> void:
	# restart() 内部会重置 emitting，one_shot 配方重新播一遍
	restart()
