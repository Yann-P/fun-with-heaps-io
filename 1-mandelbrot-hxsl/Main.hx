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
		@const var N = 20;

		function fragment() {
			var st = vec2(absolutePosition.x, absolutePosition.y) / vec2(width, height);
			st.x *= width / height;
			var z = (st-vec2(1.0,0.5))*2.0;
			var c = (st-vec2(1.0,0.5))*2.0;
			var y = 0.;
			for (i in  0...N) {
				z = c + vec2(z.x*z.x+z.y*-z.y, z.x*z.y+z.y*z.x);  // <=> c + z * mat2(z.x,-z.y,z.yx);
				if(dot(z, z) > 4.0) break;
					y += 1;
			}
			pixelColor = vec4(y / N, pixelColor.g, pixelColor.b, 1.0);
		}

	};

	public function new(w: Float, h: Float) {
		super();
		width = w;
		height = h;
	}

}


class Main extends hxd.App {

	override function init() {
		var g = new Graphics(s2d);
		g.beginFill(0x000000);
		g.drawRect(0, 0, s2d.width, s2d.height);
		g.endFill();
		g.addShader(new Mandelbrot(s2d.width, s2d.height));
	}

	static function main() {
		new Main();
	}

}
