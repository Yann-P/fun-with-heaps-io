import h3d.Vector;
import h3d.Matrix;
import h3d.scene.Object;
import hxd.IndexBuffer;
import h3d.prim.Polygon;
import h3d.col.Point;
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

class SubCube {
	private var _obj:Object = null;
	private var _baseTransform:Matrix = new Matrix();
	private var _turnTransform:Matrix = new Matrix();
	private var _pos:Vector = new Vector(0, 0, 0);

	public function new(parent:Object, pos:Vector) {
		_obj = new Object(parent);
		_pos = pos;

		_turnTransform.identity();

		_baseTransform.identity();		
		_baseTransform.scale(.95, .95, .95);
		_baseTransform.translate(pos.x, pos.y, pos.z);

		var a = new SubCubeFace(_obj, 0xffff00);
		var b = new SubCubeFace(_obj, 0xff0000);
		b.rotate(Math.PI / 2, 0, 0);
		var c = new SubCubeFace(_obj, 0x0099ff);
		c.rotate(0, 0, Math.PI / 2);
		var d = new SubCubeFace(_obj, 0x00ff00);
		d.rotate(0, 0, -Math.PI / 2);
		var e = new SubCubeFace(_obj, 0xff9900);
		e.rotate(-Math.PI / 2, 0, 0);
		var f = new SubCubeFace(_obj, 0xffffff);
		f.rotate(Math.PI, 0, 0);

		_obj.setTransform(_baseTransform);
		
	}

	public function move(axis: UInt, direction: Bool, back: Bool) {
		var pos = [_pos.x, _pos.y, _pos.z][axis];
		var rotationAmount = Math.PI / 2 * (direction ? 1 : -1);
		var axis = new Vector((axis == 0 ? 1 : 0), (axis == 1 ? 1 : 0), (axis == 2 ? 1 : 0));
		
		if (pos == 0 && !back) {
			_turnTransform.rotateAxis(axis, rotationAmount);
		}
		if (pos == 2 && back) {
			_turnTransform.rotateAxis(axis, rotationAmount);
		}

		var result = new Matrix();
		result.multiply(_turnTransform, _baseTransform);
		_obj.setTransform(result);
	}
}

class SubCubeFace extends Object {
	public function new(parent:Object, color:UInt) {
		super(parent);

		var buffer = new IndexBuffer();
		var idxCounterClockwise = [0, 1, 2, 0, 2, 3];

		idxCounterClockwise.map(i -> buffer.push(i));

		// uncomment for both faces
		// var idxClockwise = idxCounterClockwise.copy();
		// idxClockwise.reverse();
		// idxClockwise.map(i -> buffer.push(i));

		var prim = new Polygon([new Point(0, 0, 0), new Point(1, 0, 0), new Point(1, 0, 1), new Point(0, 0, 1)], buffer);
		prim.addNormals();
		prim.addTangents();
		prim.translate(-.5, -.5, -.5);

		var mesh = new Mesh(prim, this);
		mesh.material.color.setColor(color);
		mesh.material.shadows = false;
	}
}

class RubiksCube {
	private var _cubes:Array<SubCube> = [];
	private var N = 3;

	public function new(parent: Object) {
		for (x in 0...N) {
			for (y in 0...N) {
				for (z in 0...N) {
					var s = new SubCube(parent, new Vector(x, y, z));
					_cubes.push(s);
				}
			}
		}
	}

	public function rotate(axis: UInt, direction: Bool, back: Bool) {
		for(c in _cubes) {
			c.move(axis, direction, back);
		}
	}

}

class Main extends hxd.App {
	var t:Float = 0;
	var _cube: RubiksCube = null;
	override function init() {
		_cube = new RubiksCube(s3d);
		s3d.lightSystem.ambientLight.set(1, 1, 1);

		new h3d.scene.CameraController(s3d).loadFromCamera();
	}

	override function update(dt:Float) {
		t += 1;//dt;
		
		// move stuff around
		if(t % 100 == 0) {
			_cube.rotate(cast(t / 100, UInt) % 3, false, false);
		}
	}

	static function main() {
		new Main();
	}
}
