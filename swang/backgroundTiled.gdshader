shader_type canvas_item;

uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform vec4 color3 : source_color;
uniform vec4 color4 : source_color;
uniform float timeScale;

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.50)));
    
	int numOctaves = 5;
	for (int i = 0; i < numOctaves; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment() {
	vec2 st = FRAGCOORD.xy * 0.005f;
    vec3 color = vec3(0.0);
	
	float t = TIME * .5;

    vec2 q = vec2(0.);
    q.x = fbm( st + 0.00* t);
    q.y = fbm( st + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( st + 1.0*q + vec2(1.7,9.2)+ 0.15 *t);
    r.y = fbm( st + 1.0*q + vec2(8.3,2.8)+ 0.126*t);

    float f = fbm(st+r);
    color = mix(color1.rgb,
                color2.rgb,
                clamp((f*f)*4.0,0.0,1.0));

    color = mix(color,
                color3.rgb,
                clamp(length(q),0.0,1.0));

    color = mix(color,
				color4.rgb,
                clamp(length(r.x),0.0,1.0));

    COLOR = vec4(color,1.);
}
