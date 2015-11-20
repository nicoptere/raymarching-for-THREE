// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
uniform vec2 resolution;
uniform float time;
uniform float randomSeed;
uniform float fov;
uniform vec3 camera;
uniform vec3 target;
uniform float raymarchMaximumDistance;
uniform float raymarchPrecision;

uniform sampler2D  texture;
uniform samplerCube cubemap;
uniform float anchors[45];
/*
Space Body
my goal was to introduce some sub-surface scattering with hot color but the result is not as expected
normaly less thnkness is more cold than big thickness. here this is the inverse ^^ its not wanted
mouse axis X for control the rock expansion
*/

#define BLOB

#define shape(p,r) length(p)-r

float dstepf = 0.0;

const vec2 RMPrec = vec2(.3, 0.01);
const vec3 DPrec = vec3(1e-5, 12., 1e-6);

// by shane : https://www.shadertoy.com/view/4lSXzh
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
#ifdef BLOB
    return  max(v.x, v.y) - max(v.z, v.w); // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
#else
    return max(v.x, v.y); // Maximum, or regular value for the regular Voronoi aesthetic.  Range [0, 1].
#endif
}

vec2 unionAB(vec2 a, vec2 b){return vec2(min(a.x, b.x),1.);}
vec2 intersectionAB(vec2 a, vec2 b){return vec2(max(a.x, b.x),1.);}
vec2 blendAB( vec2 a, vec2 b, float t ){ return vec2(mix(a.x, b.x, t ),1.);}
vec2 subtract(vec2 a, vec2 b){ return vec2(max(-a.x, b.x),1.); }
//http://iquilezles.org/www/articles/smin/smin.htm
vec2 smin( vec2 a, vec2 b, float k ) { float h = clamp( 0.5+0.5*(b.x-a.x)/k, 0.0, 1.0 ); return vec2( mix( b.x, a.x, h ) - k*h*(1.0-h), 1. ); }

#define mPi 3.14159
#define m2Pi 6.28318
vec2 uvs(vec3 p)
{
    p = normalize(p);
    return vec2( 0.5 + atan(p.z, p.x) / (m2Pi*1.1547), 0.5 - asin(p.y) / (mPi*1.5) );
}


///////////////////////////////////
vec2 map(vec3 p)
{
    dstepf += 0.003;
    /*
    vec2 res = vec2(0.);

	float voro = Voronesque(p);
	//float voro0 = Voronesque(p+1.);

 	float sp = shape(p);
    float spo = sp - voro;
    float spi = sp + voro * .5;

	float e = sin(time*.5)*.4 +.35;

   	float dist = max(-spi, spo + e);

	res = vec2(dist, 1.);

	float kernel = sp + 1.;
	if (kernel < res.x )
		res = vec2(kernel, 2.);
    //*/
    vec2 res = vec2(0.);
    for( int i = 0; i < 45; i+= 3 )
    {
        vec3 p = vec3( anchors[ i ], anchors[i+1], anchors[i+2] );
        res = unionAB( res, vec2( shape( p,1. ), 0. ) );
    }

	return res;
}

vec3 nor( vec3 pos, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
    map(pos+e.xyy).x - map(pos-e.xyy).x,
    map(pos+e.yxy).x - map(pos-e.yxy).x,
    map(pos+e.yyx).x - map(pos-e.yyx).x );
    return normalize(n);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

// return color from temperature
//http://www.physics.sfasu.edu/astro/color/blackbody.html
//http://www.vendian.org/mncharity/dir3/blackbody/
//http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
vec3 blackbody(float Temp)
{
	vec3 col = vec3(255.);
    col.x = 561e5 * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 352e5 * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

const vec3 RockColor = vec3(.2,.4,.58);
const vec3 DeepSpaceColor = vec3(0,.02,.15);

void main()
{

    vec4 f = gl_FragColor;
    vec2 g = gl_FragCoord.xy;

    vec2 si = resolution.xy;
	float t = time;

    float ca = t*.2; // angle z
    float ce = 2.; // elevation
    float cd = 4.; // distance to origin axis

    vec3 cu=vec3(0,1,0);//Change camere up vector here
    vec3 cv=vec3(0,0,0); //Change camere view here
    vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 ro = vec3(sin(ca)*cd, ce+1., cos(ca)*cd); //
    vec3 rd = cam(uv, ro, cu, cv);

    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
	vec2 s = vec2(DPrec.y, 0.);
    for(int i=0;i<200;i++)
    {
		if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
		s.x *= (s.x>DPrec.x?RMPrec.x:RMPrec.y);
		d.x += s.x;
        p = ro+rd*d.x;
   	}
    float alpha = 1.;
	if (d.x<DPrec.y)
    {
		vec3 n = nor(p, .0001);
		if( s.y < 2.5) // kernel
		{
			float b = dot(n,normalize(ro-p))*0.9;
            f = (b*vec4(blackbody(2000.),0.9)+pow(b,0.2))*(1.0-d.x*.01);
		}
		if ( s.y < 1.5) // icy color
        {
			rd = reflect(rd, n);
			p += rd*d.x;
			d.x += map(p).x * .001;
			f.rgb = exp(-d.x / RockColor / 15.);

		}

        vec3 reflRay = reflect(rd, n);
        vec3 refrRay = refract(rd, n, .75);

        vec3 cubeRefl = textureCube(cubemap, reflRay).rgb;//* refl_i;
        vec3 cubeRefr = textureCube(cubemap, refrRay).rgb;//* refr_i;

        f.rgb += cubeRefl * .5;
        f.rgb -= cubeRefr * .5;
   	}

    gl_FragColor = vec4(  anchors[0],  anchors[1],  anchors[2], 1. );//mix( f, vec4(DeepSpaceColor, 1.) * vertices[0], 1.0 - exp( -d.x*dstepf) );
}