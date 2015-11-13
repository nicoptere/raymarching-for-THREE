var Composer = function()
{
    var undef;
    var _composer = undef;

    var renderer = undef;
    var scene = undef;
    var camera = undef;
    var fxaa = undef;

    function Composer( _renderer, _scene, _camera ){

        renderer = _renderer;
        scene = _scene;
        camera = _camera;

        _composer = new THREE.EffectComposer( renderer );
        _composer.addPass( new THREE.RenderPass( scene, camera ) );

        fxaa = new THREE.ShaderPass( THREE.FXAAShader );
        fxaa.renderToScreen = true;
        _composer.addPass( fxaa );

    }

    function render()
    {
        _composer.render();
    }

    function setSize(width, height) {
        _composer.setSize(width, height);
        fxaa.uniforms.resolution.value.set( 1 / width, 1 / height );
    }

    var _p = Composer.prototype;
    _p.render = render;
    _p.setSize = setSize;
    return Composer;

}();