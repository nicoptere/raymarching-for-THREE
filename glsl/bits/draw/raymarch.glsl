//the actual raymarching from:
//https://github.com/stackgl/glsl-raytrace/blob/master/index.glsl

vec2 raymarching( vec3 rayOrigin, vec3 rayDir, float maximumDistance, float precision ) {

    float latest = precision * 2.0;
    float dist   = 0.0;
    float type   = -1.0;
    for (int i = 0; i < raymarchSteps; i++) {

        if (latest < precision || dist > maximumDistance) break;
        vec2 result = field( rayOrigin + rayDir * dist );
        latest = result.x;
        dist  += latest;
        type = result.y;
    }

    vec2  res    = vec2(-1.0, -1.0 );
    if (dist < maximumDistance) { res = vec2(dist, type ); }
    return res;

}
