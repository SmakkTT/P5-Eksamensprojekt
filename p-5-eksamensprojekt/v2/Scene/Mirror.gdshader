shader_type spatial;
render_mode unshaded; // Ingen skygger

uniform sampler2D reflection_texture : source_color;

void fragment() {
	// Spejlvend billedet (venstre/højre)
	vec2 mirror_uv = vec2(1.0 - UV.x, UV.y);
	ALBEDO = texture(reflection_texture, mirror_uv).rgb;
}