shader_type canvas_item;

// Palette swap shader for vehicle color customization
// Based on the technique from: https://www.youtube.com/watch?v=ME6of_bGkKY
//
// How it works:
// 1. The base sprite uses a specific color palette (red by default)
// 2. The palette textures are 1D textures with replacement colors
// 3. The shader samples the original color's red channel as an index into the palette

uniform sampler2D palette_texture : hint_default_black, filter_nearest, repeat_disable;
uniform bool enabled = true;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);

	if (enabled && original_color.a > 0.0) {
		// Use the red channel of the original color as the palette index
		// The palette texture is a horizontal strip where x position = color index
		// Red channel ranges from 0.0 to 1.0, mapping to palette positions
		float palette_index = original_color.r;

		// Sample the palette texture at this index (y = 0.5 for center of 1D texture)
		vec4 palette_color = texture(palette_texture, vec2(palette_index, 0.5));

		// Calculate the luminosity/brightness of the original pixel
		// This preserves shadows and highlights
		float luminosity = original_color.r;

		// Apply the palette color, preserving luminosity variations
		// Multiply palette color by luminosity to maintain shading
		vec3 final_color = palette_color.rgb * luminosity;

		// For non-red areas (like black outlines, windows), preserve original
		// Check if pixel is mostly red (saturated red color)
		float saturation = max(original_color.r - original_color.g, 0.0) + max(original_color.r - original_color.b, 0.0);

		if (saturation > 0.1) {
			// This is a colored (red) pixel - apply palette swap
			COLOR = vec4(final_color, original_color.a);
		} else {
			// This is a neutral pixel (black, white, gray) - preserve original
			COLOR = original_color;
		}
	} else {
		COLOR = original_color;
	}
}
