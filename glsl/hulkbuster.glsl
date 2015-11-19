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

mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(uu, vv, ww);
}
/////////////////////////////////////////////////////////////////////////

//primitives

float voronoiDistribution( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) );
    d = fract(sin(d)*262144.)*v*2.;
    v.x = max(d.x, d.y), v.y = max(d.z, d.w), v.z = max(min(d.x, d.y), min(d.z, d.w)), v.w = min(v.x, v.y);
	return  max(v.x, v.y) - max(v.z, v.w); // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
}
#define sphere(p, r) length(p)-r

//operations

vec2 unionAB(vec2 a, vec2 b){return vec2(min(a.x, b.x),1.);}
vec2 intersectionAB(vec2 a, vec2 b){return vec2(max(a.x, b.x),1.);}
vec2 blendAB( vec2 a, vec2 b, float t ){ return vec2(mix(a.x, b.x, t ),1.);}
vec2 subtract(vec2 a, vec2 b){ return vec2(max(-a.x, b.x),1.); }
//http://iquilezles.org/www/articles/smin/smin.htm
float smin( float a, float b, float k ) { float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 ); return mix( b, a, h ) - k*h*(1.0-h); }
vec2 smin( vec2 a, vec2 b, float k ) { return vec2( smin( a.x, b.x, k ), 1. ); }

//utils

float hash(in float n)
{
    return fract(sin(n)*43758.5453123);
}
float zigzag( float x, float m )
{
    return abs( mod( x, (2.*m) ) -m);
}

#define PI 3.1415926

/////////////////////////////////////////////////////////////////////////

// STOP ! ! !

// HAMMER TIME !

/////////////////////////////////////////////////////////////////////////


const int raymarchSteps = 100;
vec2 field( vec3 position )
{

    float e = sin(time*.5) * .5 + .5;
    float c = cos(time*.1) * .5 + .5;

    float off0 = zigzag( position.x, .25-c*.1 )+ zigzag( position.x, .15 );
    float off1 = zigzag( position.z, .12 )- zigzag( position.z, .35-c*.1 );

    float r = 31.5;
    vec3 plp = position;
    plp.y += r;
    vec2 pl = smin( vec2( sphere( plp, r + 1. )-off0, 1. ),
                    vec2( sphere( plp, r + 1. )+off1, 1. ), e );

    plp.y -= r + .75;
    vec2 sp = vec2( sphere( plp, 2. + abs( c * 2. )  ), 1. );
    sp.x += zigzag( sp.x, .25-e*.1 );

    vec2 si = vec2( sp.x - voronoiDistribution( position*.75 ), 1. );
    vec2 res = unionAB( pl, smin( sp, si, .1 ));

    //color switch
    res.y = 1.;
    if( res.x > sp.x - raymarchPrecision  )res.y = 0.;
    if( res.x > si.x - raymarchPrecision  )res.y = 0.;
    if( res.x > pl.x - raymarchPrecision )res.y = 0.5;

    return res;
}

/////////////////////////////////////////////////////////////////////////

// the methods below this need the field function

/////////////////////////////////////////////////////////////////////////


//the actual raymarching from:
//https://github.com/stackgl/glsl-raytrace/blob/master/index.glsl

vec2 raymarching( vec3 rayOrigin, vec3 rayDir, float maxd, float precis ) {

    float latest = precis * 2.0;
    float dist   = 0.0;
    float type   = 0.0;
    for (int i = 0; i < raymarchSteps; i++) {

        if (latest < precis || dist > maxd ) break;

        vec2 result = field( rayOrigin + rayDir * dist );
        if( result.x > precis ) result.x *= .3;
        latest = result.x;
        dist  += latest;
        type = result.y;

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

vec4 shading( vec3 pos, vec3 norm, vec3 rd, vec3 lightDir, vec3 lightColour, vec3 diffuse )
{
    float specularHardness = 32.;
    float specular = 2.;

   vec3 light = lightColour * max(0.0, dot(norm, lightDir));

   vec3 heading = normalize(-rd + lightDir);

   float spec = pow(max(0.0, dot( heading, norm )), specularHardness) * specular;

   light = (diffuse * light) + ( spec * lightColour);

    //normal face camera (constant environment lighting)
    norm *= calcLookAtMatrix(pos,camera,0.);
    light += texture2D( map, norm.xy / 2. + .5 ).rgb * .2;

   return vec4(light, 1.0);
}

void main() {

    vec2 p = gl_FragCoord.xy / resolution.xy;
    //background
    gl_FragColor = vec4( mix( vec3( .1 ), vec3( 1. ), vec3( 1.-p.y ) ) , 1. );

    vec3 red = vec3( .9, 0.1, 0.05);
    vec3 dark = vec3( .5, 0.1, 0.15);
    vec3 color = vec3( 0.9, 0.65, 0.05);

    vec3 rd = normalize( getRay( target-camera, p ) );
    vec2 collision = raymarching( camera, rd, raymarchMaximumDistance, raymarchPrecision );
    if ( collision.x > -0.5 )
    {
        vec3 pos = camera + rd * collision.x;
        vec3 nor = calcNormal( pos );
        vec3 lightDir = normalize( vec3( 1.,1.,0. ) );
        vec3 dif = vec3( 1. );//collision.y );

        float depth = ( 1. / log( collision.x ) );
        vec4 s0 = shading( pos,nor, rd,lightDir, red    , dif * depth );
        vec4 s1 = shading( pos,nor, rd,-lightDir, dark, dif);

        gl_FragColor = ( s0 * .5 + s1 * .5 );

        if( collision.y == 1. )gl_FragColor = shading( pos,nor, rd, normalize( camera + vec3( 0.,2.,0. ) ), color, dif * depth );

		if( collision.y == .5 )gl_FragColor = shading( pos,nor, rd, normalize( camera + vec3( 0.,2.,0. ) ), vec3(.1), dif * depth );
    }
}