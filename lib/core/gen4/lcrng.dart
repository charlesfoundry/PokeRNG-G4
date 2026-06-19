const int u32Mask = 0xffffffff;

int addU32(int left, int right) {
  return ((left & u32Mask) + (right & u32Mask)) & u32Mask;
}

int mulU32(int left, int right) {
  final a = left & u32Mask;
  final b = right & u32Mask;
  final aLow = a & 0xffff;
  final aHigh = a >>> 16;
  final bLow = b & 0xffff;
  final bHigh = b >>> 16;
  final low = aLow * bLow;
  final high = (low >>> 16) + aHigh * bLow + aLow * bHigh;
  return ((low & 0xffff) + ((high & 0xffff) * 0x10000)) & u32Mask;
}

class Lcrng {
  const Lcrng({
    required this.seed,
    required this.multiplier,
    required this.increment,
  });

  const Lcrng.arng(int seed)
    : this(seed: seed, multiplier: 0x6c078965, increment: 0x1);

  const Lcrng.arngr(int seed)
    : this(seed: seed, multiplier: 0x9638806d, increment: 0x69c77f93);

  const Lcrng.pokeRng(int seed)
    : this(seed: seed, multiplier: 0x41c64e6d, increment: 0x6073);

  const Lcrng.pokeRngReverse(int seed)
    : this(seed: seed, multiplier: 0xeeb9eb65, increment: 0x0a3561a1);

  final int seed;
  final int multiplier;
  final int increment;

  Lcrng advance(int count) {
    _validateU32(seed, 'seed');
    _validateU32(multiplier, 'multiplier');
    _validateU32(increment, 'increment');
    return Lcrng(
      seed: jumpSeed(seed, count, multiplier: multiplier, increment: increment),
      multiplier: multiplier,
      increment: increment,
    );
  }

  LcrngResult next() {
    _validateU32(seed, 'seed');
    _validateU32(multiplier, 'multiplier');
    _validateU32(increment, 'increment');
    final value = nextSeed(
      seed: seed,
      multiplier: multiplier,
      increment: increment,
    );
    return LcrngResult(seed: value, value: value);
  }

  LcrngResult nextU16() {
    final result = next();
    return LcrngResult(seed: result.seed, value: result.value >>> 16);
  }

  LcrngResult nextU16Bounded(int max, {bool modulo = true}) {
    if (max <= 0 || max > 0x10000) {
      throw ArgumentError.value(max, 'max', 'must be in 1..65536');
    }
    final result = nextU16();
    final value = modulo
        ? result.value % max
        : result.value ~/ ((0xffff ~/ max) + 1);
    return LcrngResult(seed: result.seed, value: value);
  }

  static int nextSeed({
    required int seed,
    required int multiplier,
    required int increment,
  }) {
    _validateU32(seed, 'seed');
    _validateU32(multiplier, 'multiplier');
    _validateU32(increment, 'increment');
    return addU32(mulU32(seed, multiplier), increment);
  }

  static int jumpSeed(
    int seed,
    int advances, {
    required int multiplier,
    required int increment,
  }) {
    _validateU32(seed, 'seed');
    _validateU32(multiplier, 'multiplier');
    _validateU32(increment, 'increment');
    if (advances < 0) {
      throw ArgumentError.value(advances, 'advances', 'must be non-negative');
    }

    var steps = advances;
    var accMult = 1;
    var accAdd = 0;
    var curMult = multiplier;
    var curAdd = increment;

    while (steps > 0) {
      if ((steps & 1) != 0) {
        accMult = mulU32(accMult, curMult);
        accAdd = addU32(mulU32(accAdd, curMult), curAdd);
      }
      curAdd = mulU32(curAdd, addU32(curMult, 1));
      curMult = mulU32(curMult, curMult);
      steps >>>= 1;
    }

    return addU32(mulU32(accMult, seed), accAdd);
  }

  static int distance(
    int start,
    int end, {
    required int multiplier,
    required int increment,
  }) {
    _validateU32(start, 'start');
    _validateU32(end, 'end');
    _validateU32(multiplier, 'multiplier');
    _validateU32(increment, 'increment');
    var current = start & u32Mask;
    final target = end & u32Mask;
    var count = 0;
    var bit = 1;

    var jumpMult = multiplier;
    var jumpAdd = increment;

    for (var i = 0; i < 32 && current != target; i++, bit = bit << 1) {
      if (((current ^ target) & bit) != 0) {
        current = addU32(mulU32(current, jumpMult), jumpAdd);
        count = addU32(count, bit);
      }

      jumpAdd = mulU32(jumpAdd, addU32(jumpMult, 1));
      jumpMult = mulU32(jumpMult, jumpMult);
    }

    return count;
  }
}

void _validateU32(int value, String name) {
  if (value < 0 || value > u32Mask) {
    throw ArgumentError.value(value, name, 'must be in 0..0xffffffff');
  }
}

class LcrngResult {
  const LcrngResult({required this.seed, required this.value});

  final int seed;
  final int value;
}
