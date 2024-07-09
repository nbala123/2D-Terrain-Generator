extends Node2D

const biomes = {
	'savannah' : Vector2i(),
	'mesa' : Vector2i(),
	'rocks' : Vector2i(),
	'volcano' : Vector2i(),
	'swamp' : Vector2i(),
	'flower plains' : Vector2i(),
	'dark forest' : Vector2i(),
	'plains' : Vector2i(),
	'wet plains' : Vector2i(),
	'light forest' : Vector2i(),
	'dry plains' : Vector2i(),
	'desert' : Vector2i(),
	'snow' : Vector2i(),
	'warm ocean' : Vector2i(),
	'ocean' : Vector2i(),
	'cold ocean' : Vector2i(),
	'frozen ocean' : Vector2i(),
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
	wetness.set_seed(TEST_SEED)
	temperature.set_seed(TEST_SEED + 1)
	height.set_seed(TEST_SEED + 2)


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
				var tile_temp = temperature.get_noise_2dv(tile)
				var tile_height = height.get_noise_2dv(tile)
				map.set_cell(0, tile, 0, Vector2i(tile_wet, 57))
