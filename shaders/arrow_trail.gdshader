shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.4, 0.1, 1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	// 强制着色为发光颜色
	col.rgb = glow_color.rgb * 1.5;
	// 脉冲闪烁
	float pulse = 0.7 + 0.3 * sin(TIME * 10.0);
	col.rgb *= pulse;
	COLOR = col;
}
