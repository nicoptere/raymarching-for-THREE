//http://www.kevs3d.co.uk/dev/shaders/mandelbox.html
vec2 MandleBox(vec3 pos)
{
    const int Iterations = 12;
    const float Scale = 3.0;
    const float FoldingLimit = 100.0;

    float MinRad2 = 0.15 + abs(sin(time*.25))*.75;
    vec4 scale = vec4(Scale, Scale, Scale, abs(Scale)) / MinRad2;
    float AbsScalem1 = abs(Scale - 1.0);
    float AbsScaleRaisedTo1mIters = pow(abs(Scale), float(1-Iterations));

    vec4 p = vec4(pos,1.0), p0 = p;  // p.w is the distance estimate

    for (int i=0; i<Iterations; i++)
    {
      p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;
      float r2 = dot(p.xyz, p.xyz);
      p *= clamp(max(MinRad2/r2, MinRad2), 0.0, 1.0);
      p = p*scale + p0;
      if (r2>FoldingLimit) break;
    }
    return vec2( ((length(p.xyz) - AbsScalem1) / p.w - AbsScaleRaisedTo1mIters), 1. );
}