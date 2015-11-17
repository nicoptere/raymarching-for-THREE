//http://www.kevs3d.co.uk/dev/shaders/distancefield3.html

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

float fractalNoise(in vec2 xy)
{
   const int octaves = 3;
   float w = 0.7;
   float f = 0.0;
   for (int i = 0; i < octaves; i++)
   {
      f += Noise(xy) * w;
      w *= 0.5;
      xy *= 2.333;
   }
   return f;
}