uniform vec2 resolution;
uniform float time;
#define PI 3.1415926535897932384626433832795

float hash(in float n)
{
    return fract(sin(n)*43758.5453123);
}

void main() {

    vec2 xy = ( ( gl_FragCoord.xy / resolution.xy  )- .5) * 2.;
    xy.x *= resolution.x/resolution.y;

    float length = pow( 2.,53. );
    int id = 0;
    vec2 p = vec2(0.);
    vec3 pp = vec3( 0.,0., .5 );
    vec3 lightDir = vec3( sin( time ), 1., cos( time * .5 ) );

    const int count = 200;
    for( int i = 0; i < count; i++ )
    {
        float an = sin( time * PI * .00001 ) - hash( float(i) ) * PI * 2.;

        float ra = sqrt( hash( an ) );

        p.x = lightDir.x + cos( an ) * ra;
        p.y = lightDir.z + sin( an ) * ra;

        float di = distance( xy, p );
        length = min( length, di );
        if( length == di )
        {
            id = i;
            pp.xy = p;
            pp.z = float( id )/float( count ) * ( -xy.x * 1.25 );
        }
    }

    gl_FragColor = vec4( pp + vec3( 1.) * ( 1. - max( 0.0, dot( pp, lightDir)) ), 1. );

}