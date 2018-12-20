import hxsl.Types.Vec;
import h2d.Bitmap;
import h2d.Tile;
import hxsl.Shader;
import h3d.Vector;
/*
	@author Yann Pellegrini
	@date 2018-12-11
*/

import h2d.Graphics;


class Mandelbrot extends hxsl.Shader {

	static var SRC = {

		@:import h3d.shader.Base2d;
		@param var width : Float;
		@param var height : Float;
		@param var rotation: Float;
		@param var translation: Vec2;
		@param var color: Vec3;
		var N: Int;


		function rotate(v: Vec2, a: Float): Vec2 {
			var s = sin(a);
			var c = cos(a);
			var x = v.x;
			var y = v.y;
			return vec2(c * x + s * y, -s * x + c * y);
		}

    //          x
	// 		 y
	// 	c  s
	//    -s  c

		function fragment() {
			
			var pos = rotate(absolutePosition.xy - translation, rotation);
			pos.x += width/2;
			pos.y += height/2;


			var st = vec2(pos.x, pos.y) / vec2(width, height);
			st.x *= width / height;
			var z = (st-vec2(1.0,0.5))*2.0;
			var c = (st-vec2(1.0,0.5))*2.0;
			var y = 0.;
			N = int((sin(time) * 2. + .5) * 5) + 10;
			for (i in  0...N) {
				z = c + vec2(z.x*z.x+z.y*-z.y, z.x*z.y+z.y*z.x);  // <=> c + z * mat2(z.x,-z.y,z.yx);
				if(dot(z, z) > 4.0) break;
					y += 1;
			}
			pixelColor = vec4(
				pixelColor.r + color.x * (y / N),
				pixelColor.g + color.y * (y / N),
				pixelColor.b + color.z * (y / N),
				1.
			);
		}

	};

	public function new(w: Float, h: Float, c: Vector) {
		super();
		width = w;
		height = h;
		color = c;
	}

}

class ColorShift extends hxsl.Shader {

	static var SRC = {

		@:import h3d.shader.Base2d;
		@param var n: Float;

		function fragment() {
			textureColor = vec4(
				sin(textureColor.r + time * 2 * n) / 2. + .5,
				sin(textureColor.g + time * 3 * n) / 2. + .5,
				sin(textureColor.b + time * n) / 2. + .5,
				textureColor.a
			);
		}
	};

	public function new(n: Float) {
		super();
		this.n = n;
	}

}


class Main extends hxd.App {

	public var s1: Mandelbrot;
	private var g2: Bitmap;
	private var t2: Tile;
	private var mouse = new Vector();

	override function init() {
		var interaction = new h2d.Interactive(s2d.width, s2d.height, s2d);
		interaction.onMove = function(event : hxd.Event) {
			mouse.x = event.relX;
			mouse.y = event.relY;
		}
		var g = new Graphics(s2d);
		g.beginFill(0x000000, 0);
		g.drawRect(0, 0, s2d.width, s2d.height);
		g.endFill();
		
		//g.addShader(new ColorShift(.1));
		
		g.addShader(new ColorShift(1));
		
		g2 = new Bitmap(Tile.fromColor(0, 1000, 1000, 1).center(), s2d);

		g2.x = 500;
		g2.y = 500;
		// g2.beginFill(0x000000, 0);
		// g2.drawRect(0, 0, s2d.width, s2d.height);
		// g2.endFill();


		g.addChild(g2);
	
		g.addShader(new Mandelbrot(s2d.width, s2d.height, new Vector(0,0,1)));
		s1 = new Mandelbrot(s2d.width/2, s2d.height/2, new Vector(0,1,0));

		g2.addShader(s1);
		
		//g.removeShader(s1);
		g2.addShader(new Mandelbrot(200, 200, new Vector(1, 0, 0)));
		//g2.addShader(new ColorShift(.5));
		g2.blendMode = Add;
	}

	override function update(dt: Float) {
		//g2.x++;
		//g2.removeShader(s1);
		s1.color.b = .5;
		s1.width = mouse.y;
		s1.height = mouse.y;
		g2.rotate(.01);
		s1.rotation = g2.rotation;
		s1.translation = new Vec(g2.x, g2.y);

		// g2.removeShader(s1);
		// g2.addShader(s1);


		
	}

	static function main() {
		trace('lol');
		new Main();
	}

}
