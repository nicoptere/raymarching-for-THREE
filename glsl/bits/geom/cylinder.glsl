
//requires glsl/bits/util/rotation.glsl

//http://www.pouet.net/topic.php?post=365312
vec2 cylinder( vec3 p, float h, float r, vec3 pos, vec4 quat ) {
    mat3 transform = rotationMatrix3( quat.xyz, quat.w );
    vec3 pp = (p - pos ) * transform;
    return vec2( max(length(pp.xz)-r, abs(pp.y)-h),1. );
}
vec2 cylinder( vec3 p, float h, float r, vec3 pos ) {
    vec3 pp = (p - pos );
    return vec2( max(length(pp.xz)-r, abs(pp.y)-h),1. );
}
vec2 cylinder( vec3 p, float h, float r ) {
    return vec2( max(length(p.xz)-r, abs(p.y)-h),1. );
}
