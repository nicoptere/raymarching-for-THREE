var RayMarcher = function(){

    function RayMarcher( fragmentUrl ){

        //scene setup

        this.scene = new THREE.Scene();

        this.renderer = new THREE.WebGLRenderer();
        this.renderer.setSize( window.innerWidth, window.innerHeight );
        this.domElement = this.renderer.domElement;

        this.camera = new THREE.OrthographicCamera(-1,1,1,-1,1/Math.pow( 2, 53 ),1);

        //geometry setup

        var geom = new THREE.BufferGeometry();
        geom.addAttribute( 'position', new THREE.BufferAttribute( new Float32Array([   -1,-1,0, 1,-1,0, 1,1,0, -1, -1, 0, 1, 1, 0, -1, 1, 0]), 3 ) );
        this.mesh = new THREE.Mesh( geom, null );

        this.scene.add( this.mesh );


        //load the fragment shader

        this.loaded = false;
        var scope = this;
        var req = new XMLHttpRequest();
        req.open( "GET", fragmentUrl );
        req.onload = function (e) {
            scope.setFragmentShader(e.target.responseText );
        };
        req.send();

    }

    function setFragmentShader( fs ){

        var scope = this;

        var tl = new THREE.TextureLoader();
        tl.load( "img/matcap.png", function(texture){
            scope.material.uniforms.map.value = texture;
            texture.needsUpdate = true;
        });

        this.startTime = Date.now();
        this.material = new THREE.ShaderMaterial({

            uniforms :{
                resolution:{ type:"v2", value:new THREE.Vector2( window.innerWidth, window.innerHeight ) },
                time:{ type:"f", value:0 },
                map:{ type:"t", value:null  }
            },
            vertexShader : "void main() {gl_Position = vec4( position, 1.0 );}",
            fragmentShader : fs
        });
        this.mesh.material = this.material;
        this.update();
        this.loaded = true;

    }


    function update(){

        this.renderer.setSize( window.innerWidth, window.innerHeight );
        this.material.uniforms.resolution.value.x = window.innerWidth;
        this.material.uniforms.resolution.value.y = window.innerHeight;
        this.material.uniforms.time.value = ( Date.now() - this.startTime ) * .001;
    }

    function render(){

        if( this.loaded )
        {
            this.update();
            this.renderer.render( this.scene, this.camera );
        }
    }

    var _p = RayMarcher.prototype;
    _p.constructor = RayMarcher;
    _p.setFragmentShader = setFragmentShader;
    _p.update = update;
    _p.render = render;

    return RayMarcher;
}();