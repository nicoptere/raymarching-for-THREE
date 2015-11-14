var Composer = function(){

    function Composer( raymarching ){

        this.renderer = raymarching.renderer;
        this.scene = raymarching.scene;
        this.camera = raymarching.renderCamera;

        this.composer = new THREE.EffectComposer( this.renderer );
        this.composer.addPass( new THREE.RenderPass( this.scene, this.camera ) );

        this.fxaa = new THREE.ShaderPass( THREE.FXAAShader );
        this.fxaa.renderToScreen = true;
        this.composer.addPass( this.fxaa );

    }

    function setSize(width, height) {
        this.composer.setSize(width, height);
        this.fxaa.uniforms.resolution.value.set( 1 / width, 1 / height );
    }

    function render()
    {
        this.composer.render();
    }

    var _p = Composer.prototype;
    _p.render = render;
    _p.setSize = setSize;
    return Composer;

}();