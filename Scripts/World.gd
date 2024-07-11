extends Node2D

const grounds = ['yellow rock', 'brown rock', 'red rock', 'gray rock', 'dark gray rock', 'black rock', 'white rock']

const TEST_SEED = 8767869

var biome_gen = FastNoiseLite.new()
var terrain_empty = []
@onready var window_size = get_window().size/32 + Vector2i(4, 4) #Gets window size for 'chunk' area, then adds a 2 pixel buffer on all sides
@onready var map = $TileMap
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	biome_gen.set_seed(TEST_SEED); #biome_gen.set_noise_type(FastNoiseLite.TYPE_VALUE)
	seed(TEST_SEED)
	
	for item in grounds:
		terrain_empty.append([])
		map.add_layer(-1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	generate_chunk(player.position)

func generate_chunk(pos) -> void:
	var tile_pos = map.local_to_map(pos)
	var terrain = terrain_empty.duplicate(true)
	var layers = len(terrain)
	
	for x in range(window_size.x):
		for y in range(window_size.y): 
			var tile = Vector2i(tile_pos.x - window_size.x/2 + x, tile_pos.y - window_size.y/2 + y)
			
			if map.get_cell_source_id(0, tile) == -1:
				var tile_biome = clamp(biome_gen.get_noise_2dv(tile) * 10 + 5, 0, 10)
				var true_layer = tile_biome/10*layers
				
				for z in range(true_layer):
					terrain[z].append(tile)
	
	for x in range(len(terrain)):
		map.set_cells_terrain_connect(x, terrain[x], 0, x)
	
