shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, repeat_disable, filter_nearest;
uniform int pixel_size = 1;



void fragment(){
	if (COLOR.a < 0.5) discard;
	
    float x = float(int(FRAGCOORD.x) % pixel_size);
    float y = float(int(FRAGCOORD.y) % pixel_size);

    x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
    y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

    ALBEDO = texture(screen_texture, vec2(x, y) / VIEWPORT_SIZE).xyz;
}