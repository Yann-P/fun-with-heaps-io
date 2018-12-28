import h2d.Scene;
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
		@param var color: Vec3;
		@const var N: Int = 50;

		function fragment() {
			
			var pos = calculatedUV.xy; 
			var size = vec2(width, height);
			var st = pos / size;
			var z = (st-vec2(1.0,0.5))*2.0;
			var c = (st-vec2(1.0,0.5))*2.0;
			var y = 0.;
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
		width = w * .8; // arbitrary scale to fit the fractal into the bitmap (because it's not square)
		height = h;
		color = c;
	}

}


class MandelbrotElt extends Bitmap {

	private var _parent: Scene;
	private var _vx: Float = 0;
	private var _vy: Float = 0;
	private var _width: Int = 0;
	private var _height: Int = 0;
	private var _color: Vector;
	private var _shader: Mandelbrot;

	public function new(parent: Scene, color, width = 100, height = 100) {
		super(Tile.fromColor(0, width, height, 1).center(), parent);
		_vx = Math.random() * 50 + 100;
		_vy = Math.random() * 100 + 100;
		_parent = parent;
		_width = width;
		_height = height;
		_color = color;
		_shader = new Mandelbrot(_width, _height, _color);
		addShader(_shader);
	}

	public function update(dt: Float) {
		rotate(_vx / 100 * dt);


		x += _vx * dt;
		y += _vy * dt;

		var bx = _parent.width - _width / 2;
		var by = _parent.height - _height / 2;

		if(x < 0 || x > bx) {
			_vx *= -1;
		}

		if(y < 0 || y > by) {
			_vy *= -1;
		}
	}
}


class Main extends hxd.App {

	private var entities: Array<MandelbrotElt> = [];

	override function init() {
		for(i in 0...20) {
			var m = new MandelbrotElt(s2d, new Vector(
				i % 2 == 0 ? 1 : 0, 
				i % 3 == 0 ? 1 : 0, 
				i % 5 == 0 ? 1 : 0), 200, 200);
			m.x = m.y = 300;
			m.blendMode = Add;
			this.entities.push(m);
		}
	}

	override function update(dt: Float) {
		for(e in entities) {
			e.update(dt);
		}
		
	}

	static function main() {
		new Main();
	}

}
