shader_type spatial;
render_mode cull_disabled;

uniform sampler2D door_texture : source_color;
uniform float clip_height : hint_range(-1000.0, 1000.0, 0.01) = 9999.0;

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Discard any fragment above the fixed clip line (top of door frame)
    if (world_pos.y > clip_height) {
        discard;
    }

    vec4 tex = texture(door_texture, UV);
    ALBEDO = tex.rgb;
}
