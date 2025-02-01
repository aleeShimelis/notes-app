// lib/utils/extensions.dart

extension ToggleList<T> on List<T> {
  void toggleItem(T item) {
    contains(item) ? remove(item) : add(item);
  }
}
