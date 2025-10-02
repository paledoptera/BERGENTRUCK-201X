shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, repeat_disable, filter_nearest;
uniform int cell_size = 1;

void fragment() {
	if (cell_size == 1) {
		discard;
	}
	
	vec2 num_cells = vec2(textureSize(screen_texture,0)) / float(cell_size);
	
	vec2 new_uv = floor(SCREEN_UV * num_cells) / num_cells;
	vec3 output_color = texture(screen_texture, new_uv).rgb;
	
	
	ALBEDO = output_color;
	
}