shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform int cell_size = 1;


void fragment() {
	if (cell_size == 1) {
		discard;
	}
	
	vec2 num_cells = vec2(textureSize(screen_texture,0)) / float(cell_size);
	
	vec2 new_uv = (floor(SCREEN_UV * num_cells) / num_cells) + vec2(0.015,0.015);
	vec4 output_color = texture(screen_texture, new_uv);
	
	COLOR = output_color;
	
}