
uniform vec2 resolution;
uniform float time;
uniform float fov;
uniform float raymarchMaximumDistance;
uniform float raymarchPrecision;
uniform vec3 camera;
uniform vec3 target;


//uses most of the StackGL methods
//https://github.com/stackgl

//https://github.com/hughsk/glsl-square-frame

vec2 squareFrame(vec2 screenSize) {
  vec2 position = 2.0 * (gl_FragCoord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}
vec2 squareFrame(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

//https://github.com/stackgl/glsl-look-at/blob/gh-pages/index.glsl

mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(uu, vv, ww);
}

//https://github.com/stackgl/glsl-camera-ray

vec3 getRay(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}
vec3 getRay(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix(origin, target, 0.0);
  return getRay(camMat, screenPos, lensLength);
}

/////////////////////////////////////////////////////////////////////////

mat3 rotationMatrix3(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c          );
}

/////////////////////////////////////////////////////////////////////////

//primitives

vec2 sphere( vec3 p, float radius, vec3 pos , vec4 quat)
{
    mat3 transform = rotationMatrix3( quat.xyz, quat.w );
    float d = length( ( p * transform )-pos ) - radius;
    return vec2(d,0.);
}

vec2 roundBox(vec3 p, vec3 size, float corner, vec3 pos, vec4 quat )
{
    mat3 transform = rotationMatrix3( quat.xyz, quat.w );
    return vec2( length( max( abs( ( p-pos ) * transform )-size, 0.0 ) )-corner,1.);
}

vec2 torus( vec3 p, vec2 radii, vec3 pos, vec4 quat )
{
    mat3 transform = rotationMatrix3( quat.xyz, quat.w );
    vec3 pp = ( p - pos ) * transform;
    float d = length( vec2( length( pp.xz ) - radii.x, pp.y ) ) - radii.y;
    return vec2(d,1.);
}


//operations

vec2 unionAB(vec2 a, vec2 b){return vec2(min(a.x, b.x),1.);}
vec2 intersectionAB(vec2 a, vec2 b){return vec2(max(a.x, b.x),1.);}
vec2 blendAB( vec2 a, vec2 b, float t ){ return vec2(mix(a.x, b.x, t ),1.);}
vec2 subtract(vec2 a, vec2 b){ return vec2(max(-a.x, b.x),1.); }

//http://iquilezles.org/www/articles/smin/smin.htm
vec2 smin( vec2 a, vec2 b, float k ) { float h = clamp( 0.5+0.5*(b.x-a.x)/k, 0.0, 1.0 ); return vec2( mix( b.x, a.x, h ) - k*h*(1.0-h), 1. ); }

//utils

vec3 twist( vec3 pos, float amount )
{
    vec3 p = normalize( pos );
    float c = cos(amount * p.y);
    float s = sin(amount * p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*pos.xz,pos.y);
    return q;
}

//http://www.pouet.net/topic.php?post=367360

#define pa vec3(1., 57., 21.)
#define pb vec4(0., 57., 21., 78.)
float perlin(vec3 p) {
	vec3 i = floor(p);
	vec4 a = dot( i, pa ) + pb;
	vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
	a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
}

/////////////////////////////////////////////////////////////////////////

// STOP ! ! !

// HAMMER TIME !

/////////////////////////////////////////////////////////////////////////

const int raymarchSteps = 200;
#define PI 3.14159
vec2 field( vec3 position )
{

   //position
    vec3 zero = vec3(0.);

    //rotation
    vec4 quat = vec4( 1., 0.,0.,0. );

    //twist the whole result
    position = twist( position, sin( time ) * .5 );

    //box
    vec2 box = roundBox( position, vec3(2.0,2.0,2.0),  0.5, zero, quat + vec4( 1., 1., 1., PI / 4. ) );

    //torus
    vec2 to0 = torus( position, vec2( 4.0,.15), zero, quat );
    vec2 to1 = torus( position, vec2( 4.0,.15), zero, vec4( 0., 0., 1., PI *.5 ) );

    //spheres
    vec2 sre = sphere( position, 3.0, zero, quat );
    vec2 sce = sphere( position, 1., zero, quat ) + perlin( position + time ) * .25;

    //shape composition
    float blend = .5 + sin( time * .5 ) * .5;
    vec2 _out = unionAB( sce, smin( to0, smin( to1, subtract( sre, box  ), blend ), blend ) );

    //color attribution

    //the Y value of the return value will be used to apply a different shading
    // _out.y = 1. is the default value, here, it will be attributed to blended areas
    _out.y = 1.;
    //we can retrieve the elements by depth
    //we use the raymarch precision as a threshold
    float d = raymarchPrecision;

    //then an object is found like:

    if( _out.x > box.x - d )_out.y = 0.80;
    if( _out.x > to1.x - d )_out.y = 0.66;
    if( _out.x > to0.x - d )_out.y = 0.25;
    if( _out.x > sce.x - d )_out.y = 0.;

    //or
    _out.y = 1.;
    _out.y -= step( box.x - d, _out.x ) * .2
        + 	 step( to0.x - d, _out.x ) * .35
        + 	 step( to1.x - d, _out.x ) * .75
        + 	 step( sce.x - d, _out.x ) * 1.0;

    return _out;
}

/////////////////////////////////////////////////////////////////////////

// the methods below this need the field function

/////////////////////////////////////////////////////////////////////////


//the actual raymarching from:
//https://github.com/stackgl/glsl-raytrace/blob/master/index.glsl

vec2 raymarching( vec3 rayOrigin, vec3 rayDir, float maxd, float precis ) {

    float latest = precis * 2.0;
    float dist   = 0.0;
    float type   = -1.0;
    for (int i = 0; i < raymarchSteps; i++) {

        if (latest < precis || dist > maxd) break;

        vec2 result = field( rayOrigin + rayDir * dist );
        latest = result.x;
        dist  += latest;

        type = result.y;
    }

    vec2 res    = vec2(-1.0, -1.0 );
    if (dist < maxd) { res = vec2( dist, type ); }
    return res;

}

void main() {

    vec2  screenPos    = squareFrame( resolution );

    vec3  rayDirection = getRay( camera, target, screenPos, fov );

    vec2 collision = raymarching( camera, rayDirection, raymarchMaximumDistance, raymarchPrecision );

    gl_FragColor = vec4( vec3( .25,.25,.5), 1. );

    if ( collision.x > -0.5)
    {

        //retrieve the Y value set in the field() method
        vec3 col = vec3( collision.y );

        gl_FragColor = vec4( col, 1. );

    }
}