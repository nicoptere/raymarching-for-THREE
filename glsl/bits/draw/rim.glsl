//http://www.roxlu.com/2014/037/opengl-rim-shader
vec3 rimlight( vec3 pos, vec3 nor )
{
    return vec3(smoothstep(0., 1.0, 1.0 - max(dot( normalize(-pos), nor), 0.0) ));
}
