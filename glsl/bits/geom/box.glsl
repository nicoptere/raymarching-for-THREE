
vec2 box(vec3 p, vec3 size, float corner, vec3 pos, vec4 quat )
{
    return vec2( length( max( abs( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ) )-size, 0.0 ) )-corner,1.);
}

vec2 box(vec3 p, vec3 size, vec3 pos, vec4 quat )
{
    return vec2( length( max( abs( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ) )-size, 0.0 ) ),1.);
}

vec2 box(vec3 p, vec3 pos, vec4 quat )
{
    return vec2( length( max( abs( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ) )-vec3(1.,1.,1.), 0.0 ) ),1.);
}

vec2 box(vec3 p, vec3 size, float corner, vec3 pos )
{
    return vec2( length( max( abs( p-pos )-size, 0.0 ) )-corner,1.);
}

vec2 box(vec3 p, vec3 size, vec3 pos )
{
    return vec2( length( max( abs( p-pos )-size, 0.0 ) ),1.);
}

vec2 box(vec3 p, vec3 pos )
{
    return vec2( length( max( abs( p-pos )-vec3(1.,1.,1.0), 0.0 ) ),1.);
}

vec2 box(vec3 p )
{
    return vec2( length( max( abs( p )-vec3(1.,1.,1.0), 0.0 ) ),1.);
}