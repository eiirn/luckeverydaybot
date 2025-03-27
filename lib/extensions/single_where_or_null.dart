extension SingleWhereOrNull<T> on List<T> {
  T? singleWhereOrNull(bool Function(T) test) {
    try {
      return singleWhere(test);
    } catch (err) {
      return null;
    }
  }
}
