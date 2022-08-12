shader_type canvas_item;
render_mode unshaded;

uniform float width : hint_range(0.0, 32.0);
uniform vec4 outline_color : hint_color;

void fragment() {
	vec2 size = width / vec2(textureSize(TEXTURE, 0));
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha =  sprite_color.a;
	alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	alpha = min(alpha, 1.0);
	alpha -= sprite_color.a;
	
	//COLOR = vec4(0.0);
	COLOR = sprite_color;
	COLOR += alpha * outline_color;
}