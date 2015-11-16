
//requires glsl/bits/util/rotation.glsl

vec2 torus( vec3 p, vec2 radii, vec3 pos, vec4 quat )
{
    vec3 pp = ( p - pos ) * rotationMatrix3( quat.xyz, quat.w );
    float d = length( vec2( length( pp.xz ) - radii.x, pp.y ) ) - radii.y;
    return vec2(d,1.);
}

vec2 torus( vec3 p, vec2 radii, vec4 quat )
{
    vec3 pp = p * rotationMatrix3( quat.xyz, quat.w );
    return vec2(length( vec2( length( pp.xz ) - radii.x, pp.y ) ) - radii.y,1.);
}

vec2 torus( vec3 p, vec2 radii, vec3 pos )
{
    vec3 pp = ( p - pos );
    return vec2(length( vec2( length( pp.xz ) - radii.x, pp.y ) ) - radii.y,1.);
}

vec2 torus( vec3 p, vec2 radii )
{
    return vec2(length( vec2( length( p.xz ) - radii.x, p.y ) ) - radii.y,1.);
}


vec2 torus( vec3 p, float radius, float section )
{
    return torus( p, vec2( radius, section ) );
}
vec2 torus( vec3 p, float radius, float section, vec3 pos  )
{
    return torus( p, vec2( radius, section ), pos );
}
vec2 torus( vec3 p, float radius, float section, vec4 quat )
{
    return torus( p, vec2( radius, section ), quat );
}
vec2 torus( vec3 p, float radius, float section, vec3 pos, vec4 quat )
{
    return torus( p, vec2( radius, section ), pos, quat );
}