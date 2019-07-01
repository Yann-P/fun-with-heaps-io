import hxsl.Types.Sampler2D;
import h3d.scene.Object;
import hxd.IndexBuffer;
import h3d.prim.Polygon;
import h3d.col.Point;
import h3d.prim.Quads;
import h3d.scene.DirLight;
import h3d.mat.Texture;
import h3d.mat.Material;
import h3d.scene.Mesh;
import h3d.prim.Cube;

/*
	@author Yann Pellegrini
	@date 2019-05-15
 */
class SubCubeShader extends hxsl.Shader {
	static var SRC = {
		var pixelColor:Vec4;
		@input var input:{
			var normal:Vec3;
		}
		var nn:Vec3;
		function vertex() {
			nn = (input.normal + 1) * .5;
			pixelColor.rgb = nn;
			if (nn.r == 0.5 && nn.g == 0.5 && nn.b == 1) {
				pixelColor.rgb = vec3(1, 0.5, 0);
			}
			if (nn.r == 0.5 && nn.g == 1 && nn.b == .5) {
				pixelColor.rgb = vec3(1, 1, 1);
			}
			if (nn.r == 1 && nn.g == .5 && nn.b == .5) {
				pixelColor.rgb = vec3(0, 0, 1);
			}
			if (nn.r == .5 && nn.g == 0 && nn.b == .5) {
				pixelColor.rgb = vec3(1, 1, 0);
			}
			if (nn.r == .5 && nn.g == .5 && nn.b == 0) {
				pixelColor.rgb = vec3(1, 0, 0);
			}
		}
	};

	public function new() {
		super();
	}
}

class ShadedSubCube extends Object {
	public function new(parent:Object) {
		super(parent);

		var cube = new Cube();
		cube.unindex();
		cube.addUVs();
		cube.addNormals();

		var mesh = new Mesh(cube, this);
		mesh.material.color.setColor(0x0000ff);
		mesh.material.shadows = false;
		mesh.material.mainPass.addShader(new SubCubeShader());
	}
}
		b.rotate(Math.PI / 2, 0, 0);
		var c = new SubCubeFace(this, 0x0099ff);
		c.rotate(0, 0, Math.PI / 2);
		var d = new SubCubeFace(this, 0x00ff00);
		d.rotate(0, 0, -Math.PI / 2);
		var e = new SubCubeFace(this, 0xff9900);
		e.rotate(-Math.PI / 2, 0, 0);
		var f = new SubCubeFace(this, 0xffffff);
		f.rotate(Math.PI, 0,  0);
	}
}

class SubCubeFace extends Object {
	public function new(parent: Object, color: UInt) {
		super(parent);

		var buffer = new IndexBuffer();
		var idxCounterClockwise = [0, 1, 2, 0, 2, 3];

		idxCounterClockwise.map(i -> buffer.push(i));

		// uncomment for both faces
		// var idxClockwise = idxCounterClockwise.copy();
		// idxClockwise.reverse();
		// idxClockwise.map(i -> buffer.push(i));

		var prim = new Polygon([
			new Point(0, 0, 0), 
			new Point(1, 0, 0), 
			new Point(1, 0, 1),
			new Point(0, 0, 1)], buffer);
		prim.addNormals();
		prim.addTangents();
		prim.translate(-.5, -.5, -.5);

		trace(prim.triCount());


		var mesh = new Mesh(prim, this);
		mesh.material.color.setColor(color);
		mesh.material.shadows = false;

	}
}

class Main extends hxd.App {

	var t: Float = 0;
	var b: SubCubeFace = null;

	override function init() {

		for(x in 0...3) {
			for(y in 0...3) {
				for(z in 0...3) {
					var c = new SubCube(s3d);
					c.scale(0.9);
					c.x = x;
					c.y = y;
					c.z = z;
				}
			}
		}
		
		s3d.lightSystem.ambientLight.set(1, 1, 1);

		new h3d.scene.CameraController(s3d).loadFromCamera();
	}

	override function update(dt: Float) {
		t += dt;
	}

	static function main() {
		new Main();
	}

}
