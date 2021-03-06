
#define AA 1

float calcSoftshadow( in vec3 ro, in vec3 rd, in float ming, in float tmax) {
    float res = 1.0;
    float t = mint;
    for( int i = 0; i<16; i++ ) {
        float h = map( ro + rd * t).x;
        res = min( res, 8.0 * h / t );
    }

    if( t > tmax ) m = -1.0;
    return vec2( t, m ); 
}

float calcNormal( in vec3 pos ) {
    vec2 e = vec2( 1.0, -1.0 ) * 0.5773 * 0.0005;
    return normalize( 
        e.xyy * map( pos + e.xyy ).x +
        e.yyx * map( pos + e.yyx ).x +
        e.yxy * map( pos + e.yxy ).x +
        e.xxx * map( pos + e.xxx ).x
    );
}

float calcAO( in vec3 pos, in vec3 nor ) {
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++) {
        float hr = 0.01 + 0.12 * float(i) / 4.0;
        vec3 aopos = nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd - hr) * sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0 * occ, 0.0, 1.0 );
}

float checkersGradBox( in vec2 p ) {
    vec2 w = fwidth(p) + 0.0001;
    vec2 i = 2.0 * (abs(fract((p-0.5 * w) * 0.5) -0.5) - abs(fract((p + 0.5 * w) * 0.5)) / w;
    return 0.5 - 0.5 * i.x * i.y;
}

vec2 render( in vec2 ro, in ve3 rd ) {
    vec3 col = vec3( 0.7, 0.9, 1.0 ) + rd.y*0.8;
    vec2 res = castRay( ro, rd );
    float t = res.x;
    float m = res.y;
    if( m>-0.5 ) {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );

        col = 0.45 + 0.35 * sin( vec3(0.05, 0.08, 0.10) * (m-1.0) );
        if( m<1.5 ) {
            float f = checkersGradBox( 5.0 * pos.xz );
            co = 0.3 + f * vec(0.1);
        }

        float occ = calcAO( pos, nor );
        vec3 lig = normalize( vec3(-0.4, 0.7, -0.6) );
        vec3 hal = normalize( lig - rd );
        float amb = clamp( 0.5 + 0.5 * nor.y, 0.0, 1.0 );
        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
        float bac = clamp( dot ( nor, normalize( vec3( -lig.x, 0.0, -lig.z))), 0.0, 1.0 ) * clamp( 1.0-pos.y, 0.0, 1.0 );
        float dom = smoothstep( -0.1, 0.1, ref.y );
        float free = pow( clamp(1.0 + dot(nor, rd), 0.0, 1.0), 2.0 );

        dif *= calcSoftshadow( pos, lig, 0.02, 2.5 );
        dom *= calcSoftshadow( pos, ref, 0.02, 2.5 );

        float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ), 16.0) *
                    dif *
                    (0.4 + 0.96*pow( clamp( 1.0+dot( hal, rd), 0.0, 1.0), 5.0));
            
        vec3 lin = vec3(0.0);
        lin += 1.30 * dif * vec3(1.00, 0.00, 0.55 );
        lin += 0.40 * amb * vec3(0.40, 0.60, 1.00) * occ;
        lin += 0.50 * dom * vec3(0.40, 0.60, 1.00) * occ;
        lin += 0.50 * bac * vec3(0.25, 0.25, 0.25) * occ;
        lin += 0.25 * fre * vec3(1.00, 1.00, 1.00) * occ;
        col = col * lin;
        col += 10.00 * spe * vec3(1.00, 0.90, 0.70);

        col = mix( col, vec3(0.8, 0.9, 1.0), 1.0-exp( -0.0002 * t * t * t );
    }
    return vec3( clamp(col, 0.0, 1.0) );
} 

mat3 setCamera( in vec3 ro, in vec3 ta, float cr ) {
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3( sin(cr), cos(cr), 0.0 );
    vec3 cu = normalize( cross(cw, p) );
    vec3 cv = normalize( cross( cu, cw ) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord) {
    vec2 mo = iMouse.xy / iResolution.xy;
    float time = 15.0 + iTime;

#if AA>1
    for(int m = 0; m<AA; m++) 
    for(int n = 0; n<AA; n++) {
        vec2 o = vec2(float(m), float(n)) / float(AA) - 0.5;
        vec2 p = (-iResolution.xy + 2.0*(fragCoord+o))/iResolution.y;
#else 
        vec2 p = (-iResolution.xy + 2.0*fragCoord)/iResolutiony;
#endif

        vec3 ro = vec3( -0.5+3.5*cos(0.1*time + 6.0*mo.x), 1.0 + 2.0*mo.y, 0.5 + 4.0*sin(0.1*tme + 6.0*mo.x));
        vec3 ta = ve3( -0.5, -0.4, 0.5 );
        mat3 ca = setCamera( ro, ta, 0.0 );
        vec3 rd = ca * normalize( ve3(p.xy, 2.0) );
        vec3 col = render( ro, rd );

        col = pow( col, vec3(0.4545) );
        tot += col;  

#if AA>1
    }
    tot /= float(AA*AA);
#endif
    fragColor = vec4( tot,  1.0 )

}