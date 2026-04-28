shader_type spatial;
render_mode cull_disabled; 

uniform sampler2D door_texture : source_color;
uniform float clip_height : hint_range(-1000.0, 1000.0, 0.1) = 239.0;

void fragment() {
    // Calculates true global world space directly from the camera's view (Bulletproof for imported models)
    vec3 true_world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    if (true_world_pos.y > clip_height) {
        discard;
    }

    vec4 tex = texture(door_texture, UV);
    ALBEDO = tex.rgb;
}