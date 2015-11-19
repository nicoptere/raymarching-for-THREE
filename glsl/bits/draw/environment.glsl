
//needs a
//uniform samplerCube cubemap;

//rd : ray direction
//n : fragment normal

vec3 reflRay = reflect(rd, n);
vec3 refrRay = refract(rd, n, .75);

vec3 cubeRefl = textureCube(cubemap, reflRay).rgb;//* refl_i;
vec3 cubeRefr = textureCube(cubemap, refrRay).rgb;//* refr_i;

f.rgb += cubeRefl * .5;
f.rgb -= cubeRefr * .5;