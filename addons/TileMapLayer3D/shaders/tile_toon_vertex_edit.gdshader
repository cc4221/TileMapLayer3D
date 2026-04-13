shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

// ==========================================
// VERTEX EDIT SETTINGS
// ==========================================
group_uniforms Vertex_Edit;
uniform sampler2D albedo_texture : source_color, filter_nearest, repeat_disable;
uniform float alpha_threshold = 0.5;
uniform bool debug_show_backfaces = true;

// ==========================================
// TOON LIGHTING BASE
// ==========================================
group_uniforms Lighting_Base;
// Number of discrete color steps in the shading
uniform int cuts : hint_range(1, 256) = 3;
// Softness of the transition between toon steps
uniform float step_smoothness : hint_range(0.0, 1.0) = 0.1;
uniform float wrap : hint_range(-2.0, 2.0) = 0.0;
uniform float steepness : hint_range(1.0, 8.0) = 1.0;
uniform bool use_attenuation = true;
uniform bool clamp_diffuse_to_max = false;

// ==========================================
// SHADOW STYLIZATION
// ==========================================
group_uniforms Shadow_Stylization;
uniform bool use_ramp = false;
uniform sampler2D ramp_texture : source_color;
uniform vec4 shadow_tint : source_color = vec4(0.2, 0.2, 0.3, 1.0);
uniform float shadow_tint_amount : hint_range(0.0, 1.0) = 0.3;
uniform bool use_borders = false;
// Width of the dark line between toon lighting steps
uniform float border_width : hint_range(0.0, 0.5, 0.001) = 0.01;

// ==========================================
// SPECULAR & NORMAL MAP
// ==========================================
group_uniforms Specular;
uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0, 1.0) = 1.0;
uniform float specular_shininess : hint_range(0.0, 32.0) = 16.0;
// Edge softness for the stylized specular spot
uniform float specular_softness : hint_range(0.0, 1.0) = 0.1;

group_uniforms Normal_Map;
uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 1.0) = 1.0;

// ==========================================
// RIM LIGHT
// ==========================================
group_uniforms Rim_Light;
uniform bool use_rim = true;
uniform vec4 rim_color : source_color = vec4(1.0);
uniform float rim_amount : hint_range(0.0, 16.0) = 2.0;
uniform float rim_smoothness : hint_range(0.0, 1.0) = 0.2;
uniform float rim_mask_shadow : hint_range(0.0, 1.0) = 1.0;
uniform float rim_blend : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	// Flip normal for back faces so lighting is correct with cull_disabled
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}

	vec4 tex_color = texture(albedo_texture, UV);
	if (tex_color.a < alpha_threshold) {
		discard;
	}

	// Show backfaces as RED to indicate face direction (matches MultiMesh shader)
	// Helps users identify which side will be visible after baking (which uses backface culling)
	if (debug_show_backfaces && !FRONT_FACING) {
		ALBEDO = vec3(1.0, 0.0, 0.0);
	} else {
		ALBEDO = tex_color.rgb;
	}

	// Apply normal map if available
	if (normal_strength > 0.0) {
		vec3 normal_map_sample = texture(normal_texture, UV).rgb;
		NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), normal_map_sample, normal_strength);
	}
}

