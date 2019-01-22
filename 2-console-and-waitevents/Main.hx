import hxd.WaitEvent;
import h2d.Console;
import h3d.mat.Texture;
import h2d.Particles;
/*
	@author Yann Pellegrini
	@date 2019-01-05
*/

class Main extends hxd.App {

	private var console: Console;
	private var wes: Array<WaitEvent> = [];
	private var wesByTids: Map<Int, Array<WaitEvent>> = new Map();


	override function init() {
		console = new Console(hxd.res.DefaultFont.get(), s2d);

		registerStartCmd();
		registerStopCmd();
	}

	inline private function registerStartCmd() {
		var args = [{
			name: 'timerId',
			t: AInt,
			opt: false
		}, {
			name: 'word',
			t: AString,
			opt: false
		}];

		var cb = function (timerId: Int, str: String) {
			for(i in 0...10) { 
				var we = new WaitEvent();

				wesByTids.set(timerId, 
					wesByTids.exists(timerId)
						? wesByTids.get(timerId).concat([we])
						: [we]);

				wes.push(we);
				we.wait(i, function() {
					console.log(str);
					wes.remove(we);
					wesByTids.get(timerId).remove(we);
				});
			};
		}

		console.addCommand('start', 'starts a timer', args, cb);
	}


	inline private function registerStopCmd() {
		var args = [{
			name: 'timerId',
			t: AInt,
			opt: false
		}];

		var cb = function (timerId: Int, str: String) {
			if(!wesByTids.exists(timerId)) {
				return console.log('No such timer');
			}
			for(we in wesByTids.get(timerId)) {
				we.clear();
				wes.remove(we);
			}
		}

		console.addCommand('stop', 'stops a timer', args, cb);
	}

	override function update(dt: Float) {
		trace('Updaing ${wes.length} waitevents');
		for(we in wes) {
			we.update(dt);
		}
		
	}

	static function main() {
		new Main();
	}

}
