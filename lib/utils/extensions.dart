
extension ToggleList<T> on List<T> {
  void toggleItem(T item) {
    contains(item) ? remove(item) : add(item);
  }
}

extension BoolCompare on bool {
  int compareToBool(bool other) {
    return (this == other) ? 0 : (this ? -1 : 1);
  }
}