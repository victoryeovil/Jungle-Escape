shader_type spatial;
render_mode world_vertex_coords;

uniform float sway_strength = 0.045;
uniform float sway_speed = 1.6;

void vertex() {
    float wave = sin(TIME * sway_speed + VERTEX.x * 2.1 + VERTEX.z * 1.7);
    VERTEX.x += wave * sway_strength * clamp(VERTEX.y, 0.0, 1.0);
}
