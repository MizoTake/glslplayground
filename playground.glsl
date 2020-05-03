float TIME;

vec2 rotation(vec2 v, float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a)) * v;
}

vec2 morphing(vec2 p) {
	float t = TIME * 2.5;
	int pair = int(floor(mod(t, 3.0)));
	float a = smoothstep(0.2, 0.8, mod(t, 1.0));
	if (pair == 0) return mix(vec2(abs(p.x) + abs(p.y), 0.5), vec2(length(p), 0.7), a);
	if (pair == 1) return mix(vec2(length(p), 0.7), vec2(0, 1), a);
	else return mix(vec2(0, 1), vec2(abs(p.x) + abs(p.y), 0.5), a);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
	TIME = iTime;

    float a = sin(TIME * 5.0) * 0.5 + 0.5;
    p = rotation(p, mix(0., 360., sin(TIME)));
    
    vec2 d = morphing(p);
    vec3 color = mix(vec3(1, 0.5, 0), vec3(0.3, 0.8, 1), step(d.y, d.x));

    fragColor = vec4(color, 1.0);
}

// twigl 共有
// void main(){
//   vec2 p=(gl_FragCoord.xy*2.-r)/r.y,o=vec2(abs(p.x)+abs(p.y),.5),i=vec2(0,1);
//   float a=smoothstep(.2,.8,mod(t,1.)),s=floor(mod(t,3.));
//   vec2 d=mix(mix(mix(o,vec2(length(p),.7),a),mix(vec2(length(p),.9),i,a),s),mix(i,o,a),step(2.,s));
//   p.xy=abs(p)/abs(dot(p,p))-vec2(cos(t)*.4);
//   gl_FragColor=mix(p.yxx,p.yyx,step(d.y, d.x)).xyyy;
// }