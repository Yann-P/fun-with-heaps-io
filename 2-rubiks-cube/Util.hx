@:expose
class Util {
    public static function clamp(n, low, high) {
        return Math.max(Math.min(n, high), low);
    }

    public static function map(n: Float, start1: Float, stop1: Float, start2: Float, stop2: Float, withinBounds: Bool = true): Float {
        var newval = (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
        if (!withinBounds) {
            return newval;
        }
        if (start2 < stop2) {
            return clamp(newval, start2, stop2);
        } else {
            return clamp(newval, stop2, start2);
        }
    }
}