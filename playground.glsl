#ifdef GL_ES
    precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

vec2 circle(vec2 p) {
    return vec2(length(p), 0.7);
}

vec2 square(vec2 p) {
    return vec2(abs(p.x) + abs(p.y), 0.5);
}

vec2 white(vec2 p) {
    return vec2(0, 1);	
}

vec2 rotation(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    mat2 m = mat2(c, -s, s, c);
    return m * v;
}

vec2 morphing(vec2 p) {
	float t = time * 2.5;
	
	int pair = int(floor(mod(t, 3.0)));
	
	float a = smoothstep(0.2, 0.8, mod(t, 1.0));
	
	if (pair == 0) return mix(square(p), circle(p), a);
	if (pair == 1) return mix(circle(p), white(p), a);
	else return mix(white(p), square(p), a);
}

void main() {
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
	
    float a = sin(time * 5.0) * 0.5 + 0.5;
    p = rotation(p, mix(0, 360, sin(time)));
    vec2 d = morphing(p);
    vec3 color = mix(vec3(1), vec3(0), step(d.y, d.x));

    gl_FragColor = vec4(color, 1.0);
