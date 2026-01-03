// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo_continent : source_color, filter_nearest, repeat_enable;
uniform sampler2D texture_albedo_grass : source_color, filter_nearest, repeat_enable;
uniform sampler2D texture_albedo_desert : source_color, filter_nearest, repeat_enable;

uniform int cell_continent = 0;
uniform int cell_desert = 1;
uniform int cell_grass = 1;

//uniform ivec2 albedo_texture_size;
//uniform float point_size : hint_range(0.1, 128.0, 0.1);

//uniform float roughness : hint_range(0.0, 1.0);
//uniform sampler2D texture_metallic : hint_default_white, filter_nearest, repeat_enable;
//uniform vec4 metallic_texture_channel;
//uniform sampler2D texture_roughness : hint_roughness_r, filter_nearest, repeat_enable;
//
//uniform float specular : hint_range(0.0, 1.0, 0.01);
//uniform float metallic : hint_range(0.0, 1.0, 0.01);

//uniform vec3 uv1_scale;
//uniform vec3 uv1_offset;
//uniform vec3 uv2_scale;
//uniform vec3 uv2_offset;

varying vec2 uv_continent;
varying vec2 uv_desert;
varying vec2 uv_grass;

vec4 overlay(vec4 src_col) {
	return src_col;
}

void vertex() {
//	UV = UV * uv1_scale.xy + uv1_offset.xy;
	uv_continent = UV * .25 + vec2(ivec2(cell_continent & 0x3, cell_continent / 4)) * .25;
	uv_desert = UV * .25 + vec2(ivec2(cell_desert & 0x3, cell_desert / 4)) * .25;
	uv_grass = UV * .25 + vec2(ivec2(cell_grass & 0x3, cell_grass / 4)) * .25;
//	uv_continent = UV;
}

vec4 overlay(vec4 src_col, vec4 dst_col) {
	return vec4(src_col.rgb * src_col.a + dst_col.rgb * (1.0 - src_col.a), src_col.a + dst_col.a * (1.0 - src_col.a));
}

void fragment() {
//	vec2 base_uv = UV;

//	vec4 albedo_tex = texture(texture_albedo_continent, base_uv);
	vec4 albedo_tex = texture(texture_albedo_continent, uv_continent);
	albedo_tex = overlay(texture(texture_albedo_desert, uv_desert), albedo_tex);
	albedo_tex = overlay(texture(texture_albedo_grass, uv_grass), albedo_tex);

	//albedo_tex = albedo_tex * (1.0 - ) + texture(texture_albedo_grass, uv_grass);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	//float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	//METALLIC = metallic_tex * metallic;
	//SPECULAR = specular;

	//vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	//float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	//ROUGHNESS = roughness_tex * roughness;
	ALPHA *= albedo.a * albedo_tex.a;
}
