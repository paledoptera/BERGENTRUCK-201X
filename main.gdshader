shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D palette;

void fragment()
{
	vec3 source_col = texture(TEXTURE, UV).rgb;
	vec3 closest_col = vec3(0.0);
	float smallest_error = 10.0;

	int palette_size = textureSize(palette, 0).x;
	float palette_pixel_size = 1.0 / float(palette_size);
	for (int x = 0; x < palette_size; x++)
	{
		vec3 palette_col = texture(palette, vec2(float(x) * palette_pixel_size, 0.0)).rgb;
		float error = distance(source_col, palette_col);
		if (error < smallest_error)
		{
			closest_col = palette_col;
			smallest_error = error;
		}
	}

	COLOR.rgb = closest_col;
}