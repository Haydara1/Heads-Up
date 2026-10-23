shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.5) = 0.0;
uniform float screen_width = 1152.0;
uniform float screen_height = 648.0;

void fragment() {
    float ratio = screen_width / screen_height;

    vec2 centered_uv = UV - vec2(0.5, 0.5);
    centered_uv.x *= ratio;

    float dist = length(centered_uv);

    COLOR = vec4(0.0, 0.0, 0.0, step(circle_size, dist));
}