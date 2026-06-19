import 'lcrng.dart';
import 'mt.dart';

enum CoinFlip { tails, heads }

enum PhoneCall { elm, kanto, pokerus }

class HgssRoamerRoutes {
  const HgssRoamerRoutes({
    required this.raikou,
    required this.entei,
    required this.lati,
    required this.skips,
  });

  final int? raikou;
  final int? entei;
  final int? lati;
  final int skips;

  String get routeString {
    final parts = <String>[];
    if (raikou != null) {
      parts.add('R: $raikou');
    }
    if (entei != null) {
      parts.add('E: $entei');
    }
    if (lati != null) {
      parts.add('L: $lati');
    }
    return parts.join(' ');
  }
}

class Gen4SeedVerification {
  static List<CoinFlip> coinFlips(int seed, {int count = 20}) {
    _validateSeed(seed);
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must be non-negative');
    }
    final mt = Mt(seed);
    return List<CoinFlip>.generate(count, (_) {
      return (mt.next() & 1) == 0 ? CoinFlip.tails : CoinFlip.heads;
    });
  }

  static String coinFlipString(int seed, {int count = 20}) {
    return coinFlips(
      seed,
      count: count,
    ).map((flip) => flip == CoinFlip.tails ? 'T' : 'H').join(', ');
  }

  static List<PhoneCall> phoneCalls(int seed, {int count = 20, int skips = 0}) {
    _validateSeed(seed);
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must be non-negative');
    }
    if (skips < 0) {
      throw ArgumentError.value(skips, 'skips', 'must be non-negative');
    }

    var rng = Lcrng.pokeRng(seed);
    final calls = <PhoneCall>[];
    for (var i = 0; i < count + skips; i++) {
      final result = rng.nextU16Bounded(3);
      rng = Lcrng.pokeRng(result.seed);
      if (i < skips) {
        continue;
      }
      calls.add(switch (result.value) {
        0 => PhoneCall.elm,
        1 => PhoneCall.kanto,
        _ => PhoneCall.pokerus,
      });
    }
    return calls;
  }

  static String phoneCallString(int seed, {int count = 20, int skips = 0}) {
    final calls = phoneCalls(seed, count: count, skips: skips).map((call) {
      return switch (call) {
        PhoneCall.elm => 'E',
        PhoneCall.kanto => 'K',
        PhoneCall.pokerus => 'P',
      };
    });
    return calls.join(', ');
  }

  static int callValue(int rand16) {
    _validateRand16(rand16);
    return rand16 % 3;
  }

  static List<int> chatotPitches(int seed, {int count = 20, int skips = 0}) {
    _validateSeed(seed);
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must be non-negative');
    }
    if (skips < 0) {
      throw ArgumentError.value(skips, 'skips', 'must be non-negative');
    }

    var rng = Lcrng.pokeRng(seed);
    final pitches = <int>[];
    for (var i = 0; i < count + skips; i++) {
      final result = rng.nextU16();
      rng = Lcrng.pokeRng(result.seed);
      if (i < skips) {
        continue;
      }
      pitches.add(chatotPitch(result.value));
    }
    return pitches;
  }

  static String chatotPitchString(int seed, {int count = 20, int skips = 0}) {
    return chatotPitches(
      seed,
      count: count,
      skips: skips,
    ).map((pitch) => pitch.toString()).join(', ');
  }

  static int chatotPitch(int rand16) {
    _validateRand16(rand16);
    return ((rand16 % 8192) * 100) >> 13;
  }

  static HgssRoamerRoutes hgssRoamerRoutes({
    required int seed,
    required bool raikouActive,
    required bool enteiActive,
    required bool latiActive,
    required int raikouRoute,
    required int enteiRoute,
    required int latiRoute,
  }) {
    _validateSeed(seed);
    if (raikouActive) {
      _validateJohtoRoamerRoute(raikouRoute, 'raikouRoute');
    }
    if (enteiActive) {
      _validateJohtoRoamerRoute(enteiRoute, 'enteiRoute');
    }
    if (latiActive) {
      _validateKantoRoamerRoute(latiRoute, 'latiRoute');
    }

    var rng = Lcrng.pokeRng(seed);
    var skips = 0;
    int? raikou;
    int? entei;
    int? lati;

    if (raikouActive) {
      do {
        skips++;
        final result = rng.nextU16();
        rng = Lcrng.pokeRng(result.seed);
        raikou = hgssJohtoRoamerRoute(result.value);
      } while (raikou == raikouRoute);
    }

    if (enteiActive) {
      do {
        skips++;
        final result = rng.nextU16();
        rng = Lcrng.pokeRng(result.seed);
        entei = hgssJohtoRoamerRoute(result.value);
      } while (entei == enteiRoute);
    }

    if (latiActive) {
      do {
        skips++;
        final result = rng.nextU16();
        rng = Lcrng.pokeRng(result.seed);
        lati = hgssKantoRoamerRoute(result.value);
      } while (lati == latiRoute);
    }

    return HgssRoamerRoutes(
      raikou: raikou,
      entei: entei,
      lati: lati,
      skips: skips,
    );
  }

  static int hgssJohtoRoamerRoute(int rand16) {
    _validateRand16(rand16);
    final value = rand16 & 15;
    return value < 11 ? value + 29 : value + 31;
  }

  static int hgssKantoRoamerRoute(int rand16) {
    _validateRand16(rand16);
    final value = rand16 % 25;
    return switch (value) {
      22 => 24,
      23 => 26,
      24 => 28,
      _ => value + 1,
    };
  }
}

void _validateSeed(int seed) {
  if (seed < 0 || seed > u32Mask) {
    throw ArgumentError.value(seed, 'seed', 'must be in 0..0xffffffff');
  }
}

void _validateRand16(int rand16) {
  if (rand16 < 0 || rand16 > 0xffff) {
    throw ArgumentError.value(rand16, 'rand16', 'must be in 0..65535');
  }
}

void _validateJohtoRoamerRoute(int route, String name) {
  if (!(_johtoRoamerRoutes.contains(route))) {
    throw ArgumentError.value(route, name, 'must be a HGSS Johto roamer route');
  }
}

void _validateKantoRoamerRoute(int route, String name) {
  if (!(_kantoRoamerRoutes.contains(route))) {
    throw ArgumentError.value(route, name, 'must be a HGSS Kanto roamer route');
  }
}

const _johtoRoamerRoutes = {
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  42,
  43,
  44,
  45,
  46,
};

const _kantoRoamerRoutes = {
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  24,
  26,
  28,
};
