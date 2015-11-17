# raymarching-for-THREE
![screenshot](https://rawgit.com/nicoptere/raymarching-for-THREE/master/img/cover.jpg)
<br/>
a "helper" to work with raymarching in THREE.js.
* [basic demo](https://rawgit.com/nicoptere/raymarching-for-THREE/master/index.html)<br>
* [interactive demo](https://rawgit.com/nicoptere/raymarching-for-THREE/master/interactive.html) (mouse controls)<br>
* [color segmentation](https://rawgit.com/nicoptere/raymarching-for-THREE/master/colors.html)<br>

it is heavily based on http://stack.gl/ core modules & scripts<br>
<br>
[THREE.js](http://threejs.org/) is a popular WebGL library, Raymarching Distance Fields is trendy nowadays, this is a way to bring them together. most of (all!) the work is done by the fragment shader, do not expect anything even remotely complex on the javascript side :)<br>
THREE makes it easy to upload various data to the shader (cameras, lights, textures for instance), another benefit is to be able to use THREE's post-processing ecosystem ; in the example above, I used a FXAA Pass to smooth the result. <br>
I've just left a small subset of the post processing & shaders folder for the sake of testing but there 's a lot more on THREE's repo.<br>
<br>
I've left the links to the resources I used in the [fragment file](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/fragment.glsl), most of the changes should be done in the "field()" method after the [HAMMER TIME!](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/fragment.glsl#L126)

# sample script

    <script src="three.min.js"></script>
    <script src="raymarcher.js"></script>
    <script>
        var rm;
        function init() {

            var w = window.innerWidth;
            var h = window.innerHeight;

            rm = new RayMarcher().setSize( w,h ).loadFragmentShader( "glsl/noise_bulb.glsl" );
            document.body.appendChild( rm.domElement );

        }

        function animate() {

            requestAnimationFrame( animate );
            rm.render();

        }
        init();
        animate();
    </script>

should give you something like this:
![noise bulb](https://cdn.rawgit.com/nicoptere/raymarching-for-THREE/master/img/noise_bulb.jpg)<br>
[noise bulb demo](https://rawgit.com/nicoptere/raymarching-for-THREE/master/noise_bulb.html)<br>

for the sake of exhibiting the beauty of Raymarching, the above shape is produced by [this distance estimator](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/noise_bulb.glsl#L171-L186):

    vec2 field( vec3 position ){

        //create a 5 units radius sphere
        vec2 sph = sphere( position, 5. );

        //create a 10 units high, 4 units radius cylinder and positions it at Y = -12.5 units
        vec2 cyl = cylinder( position, 10.,4., vec3( 0.,-12.5,0.) );

        //stores a copy of the position being evaluated
        vec3 nPos = position * .45;

        //adds some delta
        nPos.y -= time * .05;

        //creates a transform (time-based rotation about the Y axis)
        vec4 quat = vec4( 0., 1., 0., -time * .1 );

        //evaluates a noise field using the transform above (the noise field "rotates")
        vec2 noi = vec2( max( -.5, .5-abs( perlin( nPos, quat ) ) ), 0. );

        //combines the shapes:
        // 1 - blends the sphere and the cylinder
        // 2 - return s the intersection of the blended shapes with the noise field
        return intersectionAB( smin( sph, cyl, .99 ), noi );

    }

then some [colors are being computed](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/noise_bulb.glsl#L270-L286) with the result of this evaluation.

# differents colors:
![colors](https://cdn.rawgit.com/nicoptere/raymarching-for-THREE/master/img/colors.png)
to assign different colors to the different parts of the shape you can do somethign like:<br>

    //shape composition
    float blend = .5 + sin( time * .5 ) * .5;
    vec2 _out = unionAB( sce, smin( to0, smin( to1, subtract( sre, box  ), blend ), blend ) );

    //color attribution

    //the Y value of the return value will be used to apply a different shading
    // _out.y = 1. is the default value, here, it will be attributed to blended areas

    //we can retrieve the elements by depth
    //we use the raymarch precision as a threshold
    float d = raymarchPrecision;

    //then an object is found like:

    if( _out.x > box.x - d )_out.y = 0.80;
    if( _out.x > to1.x - d )_out.y = 0.66;
    if( _out.x > to0.x - d )_out.y = 0.25;
    if( _out.x > sce.x - d )_out.y = 0.;

    return _out;

check out the [live demo for the color selection](https://rawgit.com/nicoptere/raymarching-for-THREE/master/colors.html)<br>
see [the source shader](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/colors.glsl#L161-L181) for the code.<br>

# using the effectComposer

    <!-- import three and the raymarcher /-->
    <script src="vendor/three.min.js"></script>
    <script src="raymarcher.js"></script>

    <!-- import the postprocessing / shaders you need /-->
    <script src="vendor/postprocessing/EffectComposer.js"></script>
    <script src="vendor/postprocessing/RenderPass.js"></script>
    <script src="vendor/postprocessing/ShaderPass.js"></script>
    <script src="vendor/postprocessing/MaskPass.js"></script>
    <script src="vendor/shaders/CopyShader.js"></script>
    <script src="vendor/shaders/FXAAShader.js"></script>

    <!-- alter the composer class to perform what you want /-->
    <script src="composer.js"></script>

    <script>

        var rm;
        var composer;
        function init() {

            [instantiate raymarcher as above]

            //pass the raymarcher to the Composer
            composer = new Composer( rm );
            composer.setSize( w,h );

        }

        function animate() {

            [ call rm.render() ]

            if( rm.loaded )composer.render();

        }

        init();
        animate();

    </script>
the composer contains whatever filters you can think of and is called after the RayMarcher' render<br>



# tips

retrieve depth:
    float depth = ( 1./ log( collision.x ) );
scale an object:
    primitive( ( position/scale ) ) * scale;
repeat a shape at a given interval (described by a vec3 r ):
    vec3 repeat( vec3 p, vec3 r ) { return mod( p, r ) - .5 * r; }
spherical uvs:
    texture2D( map, nor.xy / 2. + .5 );
    (you can [lookat](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/bits/util/lookat.glsl) the camera to always face the it)

#wandering
![halibut](https://cdn.rawgit.com/nicoptere/raymarching-for-THREE/master/img/halibut.jpg)<br>
[halibut demo](http://barradeau.com/dump/raymarching/halibut.html)<br>

#helpful links:


WebGL [quick reference](http://www.shaderific.com/glsl/) for types, functions, statements etc.

[Jaume Sanchez Elias](https://twitter.com/thespite)'s [Shader Editor chrome extension](https://chrome.google.com/webstore/detail/shader-editor/ggeaidddejpbakgafapihjbgdlbbbpob) mandatory tool to work with shaders

[Íñgo Quílez](http://www.iquilezles.org/) [distance functions](http://iquilezles.org/www/articles/distfunctions/distfunctions.htm) and his live [example / refernce for basically everything](https://www.shadertoy.com/view/Xds3zN)

[POUET's thread on primitives, noise, AO, SSS & more]( http://www.pouet.net/topic.php?which=7931&page=1)

[Kevin Roast](https://twitter.com/kevinroast)'s [homepage](http://www.kevs3d.co.uk/dev/shaders/) is full of examples, rendering tricks, shapes and more

very interesting series of articles about distance estimators & fractals:
* [Distance Estimated 3D Fractals (Part I)](http://blog.hvidtfeldts.net/index.php/2011/06/distance-estimated-3d-fractals-part-i/)
* [Distance Estimated 3D Fractals (II): Lighting and Coloring](http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-ii-lighting-and-coloring/)
* [Distance Estimated 3D Fractals (III): Folding Space](http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/)
* [Distance Estimated 3D Fractals (IV): The Holy Grail](http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-iv-the-holy-grail/)
* [Distance Estimated 3D Fractals (V): The Mandelbulb & Different DE Approximations](http://blog.hvidtfeldts.net/index.php/2011/09/distance-estimated-3d-fractals-v-the-mandelbulb-different-de-approximations/)
* [Distance Estimated 3D Fractals (VI): The Mandelbox](http://blog.hvidtfeldts.net/index.php/2011/11/distance-estimated-3d-fractals-vi-the-mandelbox/)
* [Distance Estimated 3D Fractals (VII): Dual Numbers](http://blog.hvidtfeldts.net/index.php/2011/12/distance-estimated-3d-fractals-vii-dual-numbers/)
* [Distance Estimated 3D Fractals (Part VIII): Epilogue](http://blog.hvidtfeldts.net/index.php/2012/05/distance-estimated-3d-fractals-part-viii-epilogue/)

which incidentally reminded me of [subblue](https://twitter.com/subblue)'s [beautiful works](http://sub.blue/)

a reminder of how [the blinn-phong shading](https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_shading_model) works

<hr>