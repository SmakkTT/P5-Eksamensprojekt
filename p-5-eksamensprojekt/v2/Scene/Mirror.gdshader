shader_type spatial;
render_mode unshaded; // Prevents the mirror surface from casting/receiving shadows

uniform sampler2D reflection_texture : source_color;

void fragment() {
	// Flip the X coordinate to create a true Left/Right mirror reflection
	vec2 mirror_uv = vec2(1.0 - UV.x, UV.y);
	ALBEDO = texture(reflection_texture, mirror_uv).rgb;
}