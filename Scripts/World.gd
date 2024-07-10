extends Node2D

const grounds = ['yellow rock', 'brown rock', 'red rock', 'gray rock', 'dark gray rock', 'black rock', 'white rock']

const TEST_SEED = 8767869

var wetness = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var height = FastNoiseLite.new()
var terrain = []
var terrain_local : Array

@onready var window_size = get_window().size/32 * 1.5
@onready var map = $TileMap
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	#wetness.set_seed(TEST_SEED); wetness.set_domain_warp_enabled(true); wetness.set_domain_warp_amplitude(5.0); wetness.set_noise_type(FastNoiseLite.TYPE_VALUE )
	#temperature.set_seed(TEST_SEED + 1); temperature.set_domain_warp_enabled(true); temperature.set_domain_warp_amplitude(10.0); temperature.set_noise_type(FastNoiseLite.TYPE_VALUE)
	height.set_seed(TEST_SEED + 2); height.set_domain_warp_enabled(true); height.set_domain_warp_amplitude(20.0); height.set_noise_type(FastNoiseLite.TYPE_VALUE)
	seed(TEST_SEED)
	for item in grounds:
		terrain.append([])
		map.add_layer(-1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if int(delta) % 10 == 0:
		generate_chunk(player.position)

func generate_chunk(pos):
	var tile_pos = map.local_to_map(pos)
	terrain_local = [[], [], [], [], [], [], []]
	var layers = len(terrain_local)
	for x in range(window_size.x):
		for y in range(window_size.y): 
			var tile = Vector2i(tile_pos.x - window_size.x/2 + x, tile_pos.y - window_size.y/2 + y)
			if check_empty(layers, tile):
				print('ran')
				var tile_wet = clamp(wetness.get_noise_2dv(tile) * 10 + 5, 0, 10)
				var tile_temp = clamp(temperature.get_noise_2dv(tile) * 10 + 5, 0, 10)
				var tile_height = clamp(height.get_noise_2dv(tile) * 10 + 5, 0, 10)
				select_ground(layers, tile, tile_height)
				#map.set_cell(0, tile, 0, select_biome(tile_wet, tile_temp, tile_height))
	for x in range(len(terrain_local)):
		map.set_cells_terrain_connect(x, terrain_local[x], 0, x)

func select_ground(layers, tile, tile_height) -> void:
	var true_layer = tile_height/10*layers
	#while true_layer >= 0:
	terrain_local[true_layer].append(tile)
		#true_layer -= 1

func check_empty(layers, tile) -> bool:
	var empty = true
	for layer in range(layers):
		if map.get_cell_source_id(layer, tile) != -1:
			empty = false
			break
	return empty
