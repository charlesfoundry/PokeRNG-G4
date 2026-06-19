import 'lcrng.dart';

class Mt {
  Mt(int seed, [int advances = 0]) : _state = List<int>.filled(624, 0) {
    if (seed < 0 || seed > u32Mask) {
      throw ArgumentError.value(seed, 'seed', 'must be in 0..0xffffffff');
    }
    _state[0] = seed & u32Mask;
    for (var i = 1; i < 624; i++) {
      final previous = _state[i - 1];
      _state[i] = addU32(mulU32(0x6c078965, previous ^ (previous >>> 30)), i);
    }
    _index = 624;
    advance(advances);
  }

  final List<int> _state;
  late int _index;

  void advance(int advances) {
    if (advances < 0) {
      throw ArgumentError.value(advances, 'advances', 'must be non-negative');
    }
    for (var i = 0; i < advances; i++) {
      next();
    }
  }

  int next() {
    if (_index == 624) {
      _shuffle();
      _index = 0;
    }

    var y = _state[_index++];
    y ^= y >>> 11;
    y ^= (y << 7) & 0x9d2c5680;
    y ^= (y << 15) & 0xefc60000;
    y ^= y >>> 18;
    return y & u32Mask;
  }

  int nextU16() => next() >>> 16;

  void _shuffle() {
    for (var i = 0; i < 624; i++) {
      final y = (_state[i] & 0x80000000) | (_state[(i + 1) % 624] & 0x7fffffff);
      var next = _state[(i + 397) % 624] ^ (y >>> 1);
      if ((y & 1) != 0) {
        next ^= 0x9908b0df;
      }
      _state[i] = next & u32Mask;
    }
  }
}
