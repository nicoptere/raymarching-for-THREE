uniform vec2 resolution;
uniform float time;
uniform float fov;
uniform vec3 camera;
uniform vec3 target;
uniform float raymarchMaximumDistance;
uniform float raymarchPrecision;
uniform sampler2D map;

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

vec3 getRay(vec3 dir, vec2 pos)
{
   pos = pos - 0.5;
   pos.x *= resolution.x/resolution.y;

   dir = normalize(dir);
   vec3 right = normalize(cross(vec3(0.,1.,0.),dir));
   vec3 up = normalize(cross(dir,right));

   return dir + right*pos.x + up*pos.y;
}

/////////////////////////////////////////////////////////////////////////

//primitives

vec2 box(vec3 p, vec3 size, float corner, vec3 pos ) { return vec2( length( max( abs( p-pos )-size, 0.0 ) )-corner,1.); }

vec2 plane( vec3 p , vec3 n) { return vec2( dot(p, n), 1. ); }
vec2 plane( vec3 p , vec4 n) { return vec2( dot(p, n.xyz) - n.w, 1. ); }

//operations

vec2 unionAB(vec2 a, vec2 b){return vec2(min(a.x, b.x),1.);}
vec2 intersectionAB(vec2 a, vec2 b){return vec2(max(a.x, b.x),1.);}
vec2 blendAB( vec2 a, vec2 b, float t ){ return vec2(mix(a.x, b.x, t ),1.);}
vec2 subtract(vec2 a, vec2 b){ return vec2(max(-a.x, b.x),1.); }
//http://iquilezles.org/www/articles/smin/smin.htm
vec2 smin( vec2 a, vec2 b, float k ) { float h = clamp( 0.5+0.5*(b.x-a.x)/k, 0.0, 1.0 ); return vec2( mix( b.x, a.x, h ) - k*h*(1.0-h), 1. ); }

//utils

vec3 repeat( vec3 p, vec3 r ) { return mod( p, r ) - .5 * r; }

float hash(in float n)
{
    return fract(sin(n)*43758.5453123);
}

float noise(in vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0;
    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
    return res;
}

/////////////////////////////////////////////////////////////////////////

// STOP ! ! !

// HAMMER TIME !

/////////////////////////////////////////////////////////////////////////


const int raymarchSteps = 30;

const int shadowSteps = 4;
const int ambienOcclusionSteps = 3;
#define PI 3.14159
float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
vec2 field( vec3 position )
{

    vec3 r = vec3( 3., 0., 3. );
    vec3 p = repeat( position, r );

    position.xz += time *.5;
    float n = noise( ( .75 * position.xz / r.xz ) );

    float s = max( .5, n * 1.125 );
    float h = n * 5.;

    vec2 pl = plane( position, vec4( 0.,1.,0., h * .9 ) );
    vec2 rb = box( p, vec3( s, h, s ), .85 + ( .5+sin( time + n )*.5 ) * .1, vec3(0.) );

    vec2 _out = smin( rb, pl, .5  );
    _out.y = n;
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


        vec2 result = field( rayOrigin + rayDir * dist );
        if( result.x > precis ) result.x *= .3;
        latest = result.x;
        dist  += latest;
        type = result.y;
        if (latest < precis || dist > maxd) break;
    }

    vec2 res    = vec2(-1.0, -1.0 );
    if (dist < maxd) { res = vec2( dist, type ); }
    return res;

}


//https://github.com/stackgl/glsl-sdf-normal

vec3 calcNormal(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * field( pos + v1*eps ).x +
                    v2 * field( pos + v2*eps ).x +
                    v3 * field( pos + v3*eps ).x +
                    v4 * field( pos + v4*eps ).x );
}

vec3 calcNormal(vec3 pos) {
  return calcNormal(pos, 0.002);
}

vec4 rimlight( vec3 pos, vec3 nor )
{
    vec3 v = normalize(-pos);
    float vdn = 1.0 - max(dot(v, nor), 0.0);
    return vec4( vec3( smoothstep(0., 1.0, vdn) ), 1.);
}

vec4 shading( vec3 pos, vec3 norm, vec3 rd, vec3 lightDir, vec3 lightColour, vec3 diffuse )
{

    float specularHardness = 128.;
    float specular = 4.;
    float ambientFactor = 0.0005;

   vec3 light = lightColour * max(0.0, dot(norm, lightDir));

   vec3 heading = normalize(-rd + lightDir);

   float spec = pow(max(0.0, dot( heading, norm )), specularHardness) * specular;

   light = (diffuse * light) + ( spec * lightColour);

   return vec4(light, 1.0);
}

mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(uu, vv, ww);
}

void main() {

    vec2 p = gl_FragCoord.xy / resolution.xy;
    vec3 rd = normalize( getRay( target-camera, p ) );

    vec2 collision = raymarching( camera, rd, raymarchMaximumDistance, raymarchPrecision );


    gl_FragColor = vec4( vec3( .25,.25,.5), 1. );

    vec3 color = vec3(0.0, 0.2, 0.8);    //blue
    if ( collision.x > -0.5 )
    {

        //"world" position
        vec3 pos = camera + rd * collision.x;

        //normal vector
        vec3 nor = calcNormal( pos );

        //diffuse color
        vec3 dif = vec3( collision.y );

        //reflection (Spherical Environment Mapping)
        vec3 tex = texture2D( map, ( nor * calcLookAtMatrix( pos, camera,0. ) ).xy / 2. + .5 ).rgb;
        dif += tex * .5;

        vec3 lig = normalize( camera ) + vec3(-0.5, 0.75, -0.5) ;

        float depth = ( 1. / log( collision.x ) );
        gl_FragColor = vec4( collision.y ) + shading( pos, nor, rd, lig, color, dif ) * 1.5 * rimlight( pos, nor ) * depth;

    }
}