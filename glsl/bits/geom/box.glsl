

//-------- unit box
vec2 box(vec3 p )
{
    return vec2( length( max( abs( p )-vec3(1.), 0.0 ) ),1.);
}

//-------- variable size box

vec2 box(vec3 p, vec3 size )
{
    return vec2( length( max( abs( p )-size, 0.0 ) ),1.);
}
vec2 box(vec3 p, vec3 size, vec3 pos )
{
    return box( p-pos, size );
}



//-------- variable size box + rounded corners

vec2 box(vec3 p, vec3 size, float corner )
{
    return vec2( length( max( abs( p-pos )-size, 0.0 ) )-corner,1.);
}
vec2 box(vec3 p, vec3 size, float corner, vec3 pos )
{
    return box( p-pos, size, corner );
}


//requires glsl/bits/util/rotation.glsl

//-------- variable size box + rounded corners + transforms

vec2 box(vec3 p, vec4 quat )
{
    return return box( p * rotationMatrix3( quat.xyz, quat.w ) );
}

vec2 box(vec3 p, vec3 size, vec4 quat )
{
    return return box( p * rotationMatrix3( quat.xyz, quat.w ), size );
}

vec2 box(vec3 p, vec3 size, float corner, vec4 quat )
{
    return return box( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ), size, corner );
}

vec2 box(vec3 p, vec3 size, float corner, vec3 pos, vec4 quat )
{
    return return box( ( p-pos ) * rotationMatrix3( quat.xyz, quat.w ), size, corner );
}