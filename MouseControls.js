var MouseControls = function(){

    function MouseControls( rayMarching ){

        this.rm = rayMarching;
        this.mouseDown = false;

        rayMarching.renderer.domElement.addEventListener( "mousedown", this.onDown.bind( this ), false );
        rayMarching.renderer.domElement.addEventListener( "mousemove", this.onMove.bind( this ), false );
        rayMarching.renderer.domElement.addEventListener( "mouseup", this.onUp.bind( this ), false );
        rayMarching.renderer.domElement.addEventListener( "mouseleave", this.onUp.bind( this ), false );

    }

    function onDown(e){

        var pos = this.getPosition(e);
        this.rm.mouse.x = pos[0];
        this.rm.mouse.y = pos[1];
        this.mouseDown = true;
    }

    function onMove(e){

        if( this.mouseDown ){
            var pos = this.getPosition(e);
            this.rm.mouse.x = pos[0];
            this.rm.mouse.y = pos[1];
        }
    }

    function onUp(e){
        this.mouseDown = false;
    }

    function getPosition(e){

        var pos = [0,0];
        if( e == null )return [window.innerWidth/2, window.innerHeight/2];

        if( 'ontouchstart' in window )
        {
            var touch = e.targetTouches[0];
            pos[0] = touch.clientX;
            pos[1] = touch.clientY;
        }else
        {
            if (!e) e = window.event;
            if (e.pageX || e.pageY){
                pos[0] = e.pageX;
                pos[1] = e.pageY;
            }
            else if (e.clientX || e.clientY){
                pos[0] = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
                pos[1] = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
            }
        }
        var r = e.target.getBoundingClientRect();
        pos[0] -= r.left;
        pos[1] -= r.top;
        return pos;
    }

    var _p = MouseControls.prototype;
    
    _p.constructor = MouseControls;
    _p.onDown = onDown;
    _p.onMove = onMove;
    _p.onUp = onUp;
    _p.getPosition = getPosition;

    return MouseControls;

}();