import 'lcrng.dart';

enum PokeRngIvMethod { method12, method4 }

class LcrngReverse {
  const LcrngReverse._();

  static List<int> recoverPokeRngIvs({
    required int hp,
    required int attack,
    required int defense,
    required int specialAttack,
    required int specialDefense,
    required int speed,
    PokeRngIvMethod method = PokeRngIvMethod.method12,
  }) {
    _validateIvs(
      hp: hp,
      attack: attack,
      defense: defense,
      specialAttack: specialAttack,
      specialDefense: specialDefense,
      speed: speed,
    );
    return switch (method) {
      PokeRngIvMethod.method12 => _recoverPokeRngIvMethod12(
        hp,
        attack,
        defense,
        specialAttack,
        specialDefense,
        speed,
      ),
      PokeRngIvMethod.method4 => _recoverPokeRngIvMethod4(
        hp,
        attack,
        defense,
        specialAttack,
        specialDefense,
        speed,
      ),
    };
  }

  static List<int> recoverPokeRngPid(int pid) {
    _validatePid(pid);
    const add = 0x6073;
    const mult = 0x41c64e6d;
    const mod = 0x67d3;
    const pat = 0xd3e;
    const inc = 0x4034;

    final seeds = <int>[];
    final first = (pid << 16) & u32Mask;
    final second = pid & 0xffff0000;
    final diff = ((second - mulU32(first, mult)) & u32Mask) >>> 16;
    final start = ((((diff * mod + inc) >>> 16) * pat) % mod);

    for (var low = start; low < 0x10000; low += mod) {
      final seed = first | low;
      if ((addU32(mulU32(seed, mult), add) & 0xffff0000) == second) {
        seeds.add(seed);
      }
    }

    return seeds;
  }

  static List<int> _recoverPokeRngIvMethod12(
    int hp,
    int attack,
    int defense,
    int specialAttack,
    int specialDefense,
    int speed,
  ) {
    const add = 0x6073;
    const mult = 0x41c64e6d;
    const mod = 0x67d3;
    const pat = 0xd3e;
    const inc = 0x4034;

    final first = ((hp | (attack << 5) | (defense << 10)) << 16) & u32Mask;
    final second =
        ((speed | (specialAttack << 5) | (specialDefense << 10)) << 16) &
        u32Mask;

    final diff = ((second - mulU32(first, mult)) & u32Mask) >>> 16;
    return _recoverTwoCallSeeds(
      first: first,
      second: second,
      diff: diff,
      add: add,
      mult: mult,
      mod: mod,
      pat: pat,
      inc: inc,
    );
  }

  static List<int> _recoverPokeRngIvMethod4(
    int hp,
    int attack,
    int defense,
    int specialAttack,
    int specialDefense,
    int speed,
  ) {
    const add = 0xe97e7b6a;
    const mult = 0xc2a29a69;
    const mod = 0x3a89;
    const pat = 0x2e4c;
    const inc = 0x5831;

    final first = ((hp | (attack << 5) | (defense << 10)) << 16) & u32Mask;
    final second =
        ((speed | (specialAttack << 5) | (specialDefense << 10)) << 16) &
        u32Mask;

    final diff = ((second - addU32(mulU32(first, mult), add)) & u32Mask) >>> 16;
    return _recoverTwoCallSeeds(
      first: first,
      second: second,
      diff: diff,
      add: add,
      mult: mult,
      mod: mod,
      pat: pat,
      inc: inc,
    );
  }

  static List<int> _recoverTwoCallSeeds({
    required int first,
    required int second,
    required int diff,
    required int add,
    required int mult,
    required int mod,
    required int pat,
    required int inc,
  }) {
    final seeds = <int>[];
    final start1 = ((((diff * mod + inc) >>> 16) * pat) % mod);
    final start2 = (((((diff ^ 0x8000) * mod + inc) >>> 16) * pat) % mod);

    void recoverFrom(int start) {
      for (var low = start; low < 0x10000; low += mod) {
        final seed = first | low;
        if ((addU32(mulU32(seed, mult), add) & 0x7fff0000) == second) {
          seeds.add(seed);
          seeds.add(seed ^ 0x80000000);
        }
      }
    }

    recoverFrom(start1);
    recoverFrom(start2);
    return seeds;
  }
}

void _validateIvs({
  required int hp,
  required int attack,
  required int defense,
  required int specialAttack,
  required int specialDefense,
  required int speed,
}) {
  final values = [hp, attack, defense, specialAttack, specialDefense, speed];
  const names = [
    'hp',
    'attack',
    'defense',
    'specialAttack',
    'specialDefense',
    'speed',
  ];
  for (var index = 0; index < values.length; index++) {
    final value = values[index];
    if (value < 0 || value > 31) {
      throw ArgumentError.value(value, names[index], 'must be in 0..31');
    }
  }
}

void _validatePid(int pid) {
  if (pid < 0 || pid > u32Mask) {
    throw ArgumentError.value(pid, 'pid', 'must be in 0..0xffffffff');
  }
}
