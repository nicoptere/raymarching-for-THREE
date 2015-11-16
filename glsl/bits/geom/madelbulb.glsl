
//http://www.kevs3d.co.uk/dev/shaders/mandelbulb.html

vec2 MandelBulb(vec3 pos)
{
    const int Iterations = 12;
   const float Bailout = 8.0;
   float Power = 5.0 + sin(time*0.5)*4.0;

	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < Iterations; i++)
	{
		r = length(z);
		if (r > Bailout) break;   // TODO: test if better to continue loop and if() rather than break?

		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr = pow(r, Power-1.0)*Power*dr + 1.0;

		// scale and rotate the point
		float zr = pow(r,Power);
		theta = theta*Power;
		phi = phi*Power;

		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z += pos;
	}
	return vec2( 0.5*log(r)*r/dr, 1. );
}