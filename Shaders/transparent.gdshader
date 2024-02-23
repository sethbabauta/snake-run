shader_type canvas_item;


void fragment() {
	float alpha_threshold = 0.3;
	vec4 input_color = texture(TEXTURE, UV);
	float input_alpha = input_color.a;
	if (input_alpha > alpha_threshold) {
		input_alpha = alpha_threshold;
	}
	vec4 output_color = vec4(input_color.r, input_color.g, input_color.b, input_alpha);
	COLOR = output_color;
}

