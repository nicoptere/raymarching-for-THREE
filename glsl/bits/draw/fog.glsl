
// Fog routine - original by IQ
vec3 Fog( vec3 rgb, vec3 fogColor, vec3 rd, float distance)   // camera to point distance
{
    const float b = 0.04;
    float fogAmount = 1.0 - exp(-distance*b);
    return mix(rgb, fogColor, fogAmount);
}