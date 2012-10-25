//Ticker.addListener(window);
var canvas;
var stage;
var screen_width;
var screen_height;
var carSrc = new Image();
var car;
var gfxLoaded = 0;

var centerX = 275;
var centerY = 150;

var alive = true;

var TURN_FACTOR = 3;
var MAX_VELOCITY = 10;
var MAX_THRUST = 2;


var KEYCODE_UP = 38;
var KEYCODE_LEFT = 37;
var KEYCODE_RIGHT = 39;
var KEYCODE_W = 87;
var KEYCODE_A = 65;
var KEYCODE_D = 68;


var lfHeld;
var rtHeld;
var fwdHeld;

document.onkeydown = handleKeyDown;
document.onkeyup = handleKeyUp;

     
function init() {
  canvas = document.getElementById("race");     
  carSrc.onload = loadGfx;
  carSrc.src = "/images/car.png";
  carSrc.name = "car";
  Ticker.setFPS(30);
  Ticker.addListener(stage);
  stage = new Stage(canvas)
}
function loadGfx(e)
{
	if(e.target.name = 'car'){
		car = new Bitmap(carSrc);

	}
	gfxLoaded++;
	
	if(gfxLoaded == 1)
	{
		buildInterface();
	}
}
function buildInterface()
{
	car.x = centerX - 40;
	car.y = centerY - 12;
	car.bounds = 1;
	stage.addChild(car);
	stage.update();
	Ticker.addListener(window);
}
function tick() {
  if(alive && lfHeld && fwdHeld){
			car.rotation -= TURN_FACTOR;
		} else if(alive && rtHeld && fwdHeld) {
			car.rotation += TURN_FACTOR;
	 }
	if(alive && fwdHeld){
			carAccelerate();
	}
		 if(alive && outOfBounds(car, car.bounds)) {
			placeInBounds(car, car.bounds);
		}
	 stage.update();
}	
function carTick() {
		car.x += car.vX;
		car.y += car.vY;	
}
function carAccelerate() {
		car.x -= Math.sin(car.rotation*(Math.PI/-180))*5;
		car.y -= Math.cos(car.rotation*(Math.PI/-180))*5;

		//car.x = Math.min(MAX_VELOCITY, Math.max(-MAX_VELOCITY, car.x));
		//car.y = Math.min(MAX_VELOCITY, Math.max(-MAX_VELOCITY, car.y));		
}
	function outOfBounds(o, bounds) {
		//is it visibly off screen
		return o.x < bounds*-2 || o.y < bounds*-2 || o.x > canvas.width+bounds*2 || o.y > canvas.height+bounds*2;
	}

	function placeInBounds(o, bounds) {
		//if its visual bounds are entirely off screen place it off screen on the other side
		if(o.x > canvas.width+bounds*2) {
			o.x = bounds*-2;
		} else if(o.x < bounds*-2) {
			o.x = canvas.width+bounds*2;
		}

		//if its visual bounds are entirely off screen place it off screen on the other side
		if(o.y > canvas.height+bounds*2) {
			o.y = bounds*-2;
		} else if(o.y < bounds*-2) {
			o.y = canvas.height+bounds*2;
		}
	}
	// controls
	function handleKeyDown(e) {
		//cross browser issues exist
		if(!e){ var e = window.event; }
		switch(e.keyCode) {
			case KEYCODE_A:
			case KEYCODE_LEFT:	lfHeld = true; return false;
			case KEYCODE_D:
			case KEYCODE_RIGHT: rtHeld = true; return false;
			case KEYCODE_W:
			case KEYCODE_UP:	fwdHeld = true; return false;
		}
	}

	function handleKeyUp(e) {
		//cross browser issues exist
		if(!e){ var e = window.event; }
		switch(e.keyCode) {
			case KEYCODE_A:
			case KEYCODE_LEFT:	lfHeld = false; break;
			case KEYCODE_D:
			case KEYCODE_RIGHT: rtHeld = false; break;
			case KEYCODE_W:
			case KEYCODE_UP:	fwdHeld = false; break;
		}
	}

Zepto(function($){init();});
