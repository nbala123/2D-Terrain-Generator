extends Node2D

const biomes = {
	#biome_name : Position of main block
	'savannah' : Vector2i(2, 57),
	'rocks' : Vector2i(2, 58),
	'volcano' : Vector2i(5, 58),
	'swamp' : Vector2i(2, 59),
	'flower plains' : Vector2i(21, 57),
	'plains' : Vector2i(11, 58),
	'forest' : Vector2i(24, 57),
	'desert' : Vector2i(8, 59),
	'snow' : Vector2i(11, 59),
	'ocean' : Vector2i(11, 60),
}

const TEST_SEED = 983233

var wetness = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var height = FastNoiseLite.new()

@onready var window_size = get_window().size/32 * 1.5
@onready var map = $TileMap
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	wetness.set_seed(TEST_SEED); wetness.set_domain_warp_enabled(true); wetness.set_domain_warp_amplitude(5.0); wetness.set_noise_type(FastNoiseLite.TYPE_VALUE )
	temperature.set_seed(TEST_SEED + 1); temperature.set_domain_warp_enabled(true); temperature.set_domain_warp_amplitude(10.0); temperature.set_noise_type(FastNoiseLite.TYPE_VALUE)
	height.set_seed(TEST_SEED + 2); height.set_domain_warp_enabled(true); height.set_domain_warp_amplitude(20.0); height.set_noise_type(FastNoiseLite.TYPE_VALUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	generate_chunk(player.position)

func generate_chunk(pos):
	var tile_pos = map.local_to_map(pos)
	for x in range(window_size.x):
		for y in range(window_size.y): 
			var tile = Vector2i(tile_pos.x - window_size.x/2 + x, tile_pos.y - window_size.y/2 + y)
			if map.get_cell_source_id(0, tile) == -1:
				#Noise is non-uniform, multiplies by 10 to get [-10, 10], adds 5 for [-5, 15],
				#and clamps the unlikely upper and lower 5 to [0, 10] for more uniformity
				var tile_wet = clamp(round(wetness.get_noise_2dv(tile) * 10 + 5), 0, 10)
				var tile_temp = clamp(round(temperature.get_noise_2dv(tile) * 10 + 5), 0, 10)
				var tile_height = clamp(round(height.get_noise_2dv(tile) * 10 + 5), 0, 10)
				map.set_cell(0, tile, 0, select_biome(tile_wet, tile_temp, tile_height))

func select_biome(tile_wet, tile_temp, tile_height):
	var biome_tile : Vector2i
	if tile_height < 2:
		biome_tile = biomes['ocean']
	elif tile_height < 8:
		if tile_temp < 6:
			if tile_wet < 5:
				biome_tile = biomes['plains']
			elif tile_wet < 6:
				biome_tile = biomes['flower plains']
			elif tile_wet < 10:
				biome_tile = biomes['forest']
			else:
				biome_tile = biomes['swamp']
		else:
			if tile_wet < 5:
				biome_tile = biomes['desert']
			else:
				biome_tile = biomes['savannah']
	else:
		if tile_temp < 3:
			biome_tile = biomes['snow']
		elif tile_temp < 6:
			biome_tile = biomes['rocks']
		else:
			biome_tile = biomes['volcano']
	return biome_tile
