# raymarching-for-THREE
![screenshot](https://cdn.rawgit.com/nicoptere/raymarching-for-THREE/master/img/cover.jpg)
<br/>
a base to work with raymarching in THREE.js [live demo here](https://cdn.rawgit.com/nicoptere/raymarching-for-THREE/master/index.html)<br>
[THREE.js](http://threejs.org/) is a popular WebGL library, Raymarching Distance Fields is trendy nowadays, this is a way to bring them together. most of (all!) the work is done by the fragment shader, do not expect anything even remotely complex on the javascript side :)<br>
I've left the links to the resources I used in the [fragment file](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/fragment.glsl), most of the changes should be done in the "field()" method after the [HAMMER TIME!](https://github.com/nicoptere/raymarching-for-THREE/blob/master/glsl/fragment.glsl#L126)

<hr>
helpful links:

heavily based on http://stack.gl/ core modules & scripts<br>
distance functions: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm<br>
an example / refernce for basically everything https://www.shadertoy.com/view/Xds3zN<br>
POUET's thread on primitives, noise, AO, SSS & more http://www.pouet.net/topic.php?which=7931&page=1<br>



