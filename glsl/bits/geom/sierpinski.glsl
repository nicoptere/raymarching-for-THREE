//http://www.kevs3d.co.uk/dev/shaders/fractal.html
vec2 sierpinski(vec3 pos)
{
   const int Iterations = 14;
   const float Scale = 1.85;
   const float Offset = 2.0;

   vec3 a1 = vec3(1,1,1);
	vec3 a2 = vec3(-1,-1,1);
	vec3 a3 = vec3(1,-1,-1);
	vec3 a4 = vec3(-1,1,-1);
	vec3 c;
	float dist, d;
	for (int n = 0; n < Iterations; n++)
	{
      if(pos.x+pos.y<0.) pos.xy = -pos.yx; // fold 1
      if(pos.x+pos.z<0.) pos.xz = -pos.zx; // fold 2
      if(pos.y+pos.z<0.) pos.zy = -pos.yz; // fold 3
      pos = pos*Scale - Offset*(Scale-1.0);
	}
	return vec2( length(pos) * pow(Scale, -float(Iterations)), 1. );
}