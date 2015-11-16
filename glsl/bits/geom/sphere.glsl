
//requires glsl/bits/util/rotation.glsl

vec2 sphere( vec3 p, float radius, vec3 pos, vec4 quat)
{
    return vec2(length( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ) ) - radius,1);
}
vec2 sphere( vec3 p, float radius, vec3 pos )
{
    return vec2( length( ( p-pos) ) - radius,1);
}
vec2 sphere( vec3 p, float radius )
{
    return vec2(length( p ) - radius,1);
}