
//operations

vec2 unite(vec2 a, vec2 b){return vec2(min(a.x, b.x),1.);}
vec2 intersect(vec2 a, vec2 b){return vec2(max(a.x, b.x),1.);}
vec2 subtract(vec2 a, vec2 b){ return vec2(max(-a.x, b.x),1.); }

vec2 blend( vec2 a, vec2 b, float t ){ return vec2(mix(a.x, b.x, t ),1.);}
//http://iquilezles.org/www/articles/smin/smin.htm
vec2 smin( vec2 a, vec2 b, float k )
{
    float h = clamp( 0.5+0.5*(b.x-a.x)/k, 0.0, 1.0 );
    return vec2( mix( b.x, a.x, h ) - k*h*(1.0-h), 1. );
}
vec2 expBlend( vec2 a, vec2 b, float k )
{
    float res = exp( -k*a.x ) + exp( -k*b.x );
    return vec2( -log( res )/k, 1. );
}
vec2 powBlend( vec2 a, vec2 b, float k )
{
    float a = pow( a.x, k );
    float b = pow( b.x, k );
    return vec2( pow( (a*b)/(a+b), 1.0/k ), 1. );
}