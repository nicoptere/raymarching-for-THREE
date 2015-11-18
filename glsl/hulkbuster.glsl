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
float smin( float a, float b, float k ) { float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 ); return mix( b, a, h ) - k*h*(1.0-h); }
vec2 smin( vec2 a, vec2 b, float k ) { return vec2( smin( a.x, b.x, k ), 1. ); }

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

#define PI 3.1415926

/////////////////////////////////////////////////////////////////////////

// STOP ! ! !

// HAMMER TIME !

/////////////////////////////////////////////////////////////////////////
float zigzag( float x, float m )
{
    return abs( mod( x, (2.*m) ) -m);
}

#define shape(p, r) length(p)-r
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) );
    d = fract(sin(d)*262144.)*v*2.;
    v.x = max(d.x, d.y), v.y = max(d.z, d.w), v.z = max(min(d.x, d.y), min(d.z, d.w)), v.w = min(v.x, v.y);
	//#ifdef BLOB
    	return  max(v.x, v.y) - max(v.z, v.w); // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
	//#else
    	return max(v.x, v.y); // Maximum, or regular value for the regular Voronoi aesthetic.  Range [0, 1].
	//#endif
}

const int raymarchSteps = 100;
const int shadowSteps = 4;
const int ambienOcclusionSteps = 3;
float sdTorus88( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
vec2 field( vec3 position )
{
    vec3 p = position;// + noise( position.xz );
    /*
    vec2 pl0 = plane( p, vec4( 0.,1.,0., zigzag( position.x, .25 ) + zigzag( position.x, .15 ) ) );
    vec2 pl1 = plane( p, vec4( 0.,1.,0., zigzag( position.z, .12 ) + zigzag( position.z, .35 ) ) );
    vec2 pl = intersectionAB( pl0, pl1 );
    //*/


    float e = sin(time*.5) * .5 + .5;
    float c = cos(time*.1) * .5 + .5;
    vec3 plp = position;

    float off0 = zigzag( position.x, .25-c*.1 )+ zigzag( position.x, .15 );
    float off1 = zigzag( position.z, .12 )- zigzag( position.z, .35-c*.1 );

    float r = 31.5;
    plp.y += r;
    vec2 pl = smin( vec2( shape( plp, r + 1. )-off0, 1. ),
                    vec2( shape( plp, r + 1. )+off1, 1. ),
                   e );

    float voro = Voronesque(p*.75);

    plp.y -= r + .75;
    vec2 sp = vec2( shape( plp, 2. + abs( c * 2. )  ), 1. );
    sp.x += zigzag( sp.x, .25-e*.1 );

    vec2 spo = vec2( sp.x + voro, 1. );
    vec2 spi = vec2( sp.x - voro, 1. );
    vec2 res = unionAB( pl, smin( sp, spi, .1 ));

    float d = raymarchPrecision;
    res.y = 1.;
    if( res.x > sp.x - d  )res.y = 0.;
    if( res.x > spi.x - d  )res.y = 0.;
    if( res.x > pl.x - d )res.y = 0.5;


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

vec4 rimlight( vec3 pos, vec3 nor )
{
    vec3 v = normalize(-pos);
    float vdn = 1.0 - max(dot(v, nor), 0.0);
    return vec4( vec3( smoothstep(0., 1.0, vdn) ), 1.);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<ambienOcclusionSteps; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/float( ambienOcclusionSteps );
        vec3 aopos =  nor * hr + pos;
        float dd = field( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}

mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(uu, vv, ww);
}

vec4 shading( vec3 pos, vec3 norm, vec3 rd, vec3 lightDir, vec3 lightColour, vec3 diffuse )
{

    float specularHardness = 32.;
    float specular = 2.;
    float ambientFactor = 0.0005;

   vec3 light = lightColour * max(0.0, dot(norm, lightDir));

   vec3 heading = normalize(-rd + lightDir);

   float spec = pow(max(0.0, dot( heading, norm )), specularHardness) * specular;

   light = (diffuse * light) + ( spec * lightColour);
   //light += calcAO( pos, norm ) * ambientFactor;

    norm*=calcLookAtMatrix(pos,camera,0.);
    vec2 uv = norm.xy / 2. + .5;
    vec3 tex = texture2D( map, uv ).rgb;
    light += tex*.2;

   return vec4(light, 1.0);
}

#define mPi 3.14159
#define m2Pi 6.28318

vec2 uvs(vec3 p)
{
    p = normalize(p);
    vec2 tex2DToSphere3D;
    tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / (m2Pi*1.1547);
    tex2DToSphere3D.y = 0.5 - asin(p.y) / (mPi*1.5);
    return tex2DToSphere3D;
}

void main() {

    vec2 p = gl_FragCoord.xy / resolution.xy;
    vec3 rd = normalize( getRay( target-camera, p ) );

    vec2 collision = raymarching( camera, rd, raymarchMaximumDistance, raymarchPrecision );


    gl_FragColor = vec4( mix( vec3( .1 ), vec3( 1. ), vec3( 1.-p.y ) ) , 1. );

    vec3 red = vec3( .9, 0.1, 0.05);
    vec3 dark = vec3( .5, 0.1, 0.15);
    vec3 color = vec3( 0.9, 0.65, 0.05);

    if ( collision.x > -0.5 )
    {
        vec3 pos = camera + rd * collision.x;
        vec3 nor = calcNormal( pos );
        vec3 lightDir = normalize( vec3( 1.,1.,0. ) );
        vec3 dif = vec3( 1. );//collision.y );

        float depth = ( 1. / log( collision.x ) );
        vec2 uv = nor.xy / 2. + .5;
        vec3 tex = texture2D( map, uv ).rgb;
        dif += .1 * tex;


        vec4 s0 = shading( pos,nor, rd,lightDir, red    , dif * depth );
        vec4 s1 = shading( pos,nor, rd,-lightDir, dark, dif);

        float m = 1. / 2.;
        vec4 rim = rimlight( pos, nor );

        gl_FragColor = ( s0 * m + s1 * m );// * rim;
        if( collision.y == 1. )
        {
            vec4 s2 = shading( pos,nor, rd, normalize( camera + vec3( 0.,2.,0. ) ), color, dif * depth );
            gl_FragColor = s2;
        }

		if( collision.y == .5 )
        {
            vec4 s2 = shading( pos,nor, rd, normalize( camera + vec3( 0.,2.,0. ) ), vec3(.1), dif * depth );
            gl_FragColor = s2;
        }




    }
}