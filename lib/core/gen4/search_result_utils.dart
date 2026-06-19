typedef Gen4SearchResultKey<T> = Object Function(T result);

class Gen4SearchResultUtils {
  const Gen4SearchResultUtils._();

  static void validateMaxResults(
    int? maxResults, {
    String name = 'maxResults',
  }) {
    if (maxResults != null && maxResults <= 0) {
      throw ArgumentError.value(maxResults, name, 'must be positive');
    }
  }

  static String seedHex(int seed) {
    _validateSeed(seed);
    return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  static int seedHour(int seed) {
    _validateSeed(seed);
    return (seed >>> 16) & 0xff;
  }

  static Set<int> effectiveAllowedHours(Set<int> allowedHours) {
    validateAllowedHours(allowedHours);
    if (allowedHours.isEmpty) {
      return const {
        0,
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
        23,
      };
    }
    return allowedHours;
  }

  static void validateAllowedHours(Set<int> allowedHours) {
    for (final hour in allowedHours) {
      if (hour < 0 || hour > 23) {
        throw ArgumentError.value(
          allowedHours,
          'allowedHours',
          'must contain only values in 0..23',
        );
      }
    }
  }

  static List<T> sortedDedupedLimited<T>(
    List<T> results, {
    required int Function(T left, T right) compare,
    required Gen4SearchResultKey<T> dedupeKey,
    required int? maxResults,
  }) {
    results.sort(compare);
    final seen = <Object>{};
    results.removeWhere((result) => !seen.add(dedupeKey(result)));
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList();
    }
    return results;
  }

  static List<T> dedupedLimited<T>(
    List<T> results, {
    required Gen4SearchResultKey<T> dedupeKey,
    required int? maxResults,
  }) {
    final seen = <Object>{};
    results.removeWhere((result) => !seen.add(dedupeKey(result)));
    if (maxResults != null && results.length > maxResults) {
      return results.take(maxResults).toList();
    }
    return results;
  }
}

void _validateSeed(int seed) {
  if (seed < 0 || seed > 0xffffffff) {
    throw ArgumentError.value(seed, 'seed', 'must be in 0..0xffffffff');
  }
}
