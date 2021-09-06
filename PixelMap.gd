tool

extends TileMap

export (Texture) var palette_texture
#only supports a single line of palette cells for now, like those from https://lospec.com/palette-list, do 8px or higher
export var palette_cell_size = 32 setget set_cell_size
export (bool) var create_tileset setget create_tileset_from_palette_image
export (String) var sprite_filename = "new_sprite"
export (bool) var create_sprite setget do_sprite

#this is so you can change the variable in editor and it will update
func set_cell_size(new_size):
	palette_cell_size = new_size

func create_tileset_from_palette_image(back_to_false):
	if Engine.editor_hint:
		print("starting")
		var ts = TileSet.new()
		var num_cells = palette_texture.get_width()/palette_cell_size
		for n in num_cells:
			ts.create_tile(n)
			ts.tile_set_texture(n, palette_texture)
			ts.tile_set_tile_mode(n,TileSet.ATLAS_TILE);
			ts.tile_set_name(n,"Color_" + String(n))
			ts.tile_set_region(n, Rect2(Vector2(n*palette_cell_size,0), Vector2(1,1)))
			ts.autotile_set_size(n, Vector2.ONE)
		tile_set = ts
		print(ts.tile_get_name(0))
		cell_size = Vector2.ONE
		create_tileset = back_to_false
		create_tileset = false
		print("done!")

func do_sprite(back_to_false):
	if Engine.editor_hint:
		print("starting")
		var bounds = get_used_rect()
		var x_offset_from_zero = bounds.position.x * -1 #so if it's -7 you'll be adding that in the end
		var y_offset_from_zero = bounds.position.y * -1
		var palette_image = palette_texture.get_data() #image from palette
		var img = Image.new()
		img.create(bounds.size.x, bounds.size.y, false, Image.FORMAT_RGBA8)
		img.lock()
		palette_image.lock()
		for t in get_used_cells(): #for every Vector2 position of every used tile
			var t_id = get_cellv(t) #get it's id
			#since our palette image is 1 line, we can find the spot on the texture where that tile begins
			var pixel_coordinates = Vector2(t_id * palette_cell_size, palette_cell_size/2)
			#we can then grab it's color
			var col = palette_image.get_pixelv(pixel_coordinates)
			#and set the correct pixel on the image to that color
			img.set_pixel(t.x + x_offset_from_zero, t.y + y_offset_from_zero, col)
		img.unlock()
		palette_image.unlock();
		var new_sprite = img.save_png('res://'+sprite_filename+'.png')
		create_sprite = back_to_false
		create_sprite = false
		print("done!")
