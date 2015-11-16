
// Camera function by TekF
// Compute ray from camera parameters
vec3 GetRay(vec3 dir, vec2 pos)
{
   pos = pos - 0.5;
   pos.x *= resolution.x/resolution.y;

   dir = normalize(dir);
   vec3 right = normalize(cross(vec3(0.,1.,0.),dir));
   vec3 up = normalize(cross(dir,right));

   return dir + right*pos.x + up*pos.y;
}

vec2 city( vec3 p )
{
    float x = mod( p.z, .10 ) - mod( p.z, .50 ) + mod( p.z, .90 ) - mod( p.z, .92 );
    float y = mod( p.x, .20 ) - mod( p.x, .20 ) + mod( p.x, .40 ) - mod( p.x, .02 );
    float z = mod( p.y, .50 ) - mod( p.y, .30 ) + mod( p.y, .20 ) - mod( p.y, .12 );
    float s = 4.;
    vec3 size = vec3(max( y,z ) * s,  2., max( x,z ) * s);//z * s );x * s
    return vec2( length( max( abs( p )-size, 0.0 ) )-.1,1.);
}