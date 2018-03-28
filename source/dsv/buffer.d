module dsv.buffer;

struct Buffer(T) {
  private T[] buffer;

  private int position;

  private immutable int stepSize;

  this(immutable int stepSize) {
    this.buffer.length = stepSize;
    this.stepSize = stepSize;
  }

  void append(T row) {
    const int tmp = position + 1;
    if (tmp == buffer.length) {
      buffer.length += stepSize;
    }
    buffer[position] = row;
    position = tmp;
  }

  T get(immutable int i) {
    return buffer[i];
  }

  int length() {
    return position;
  }

  T[] data() {
    return buffer[0..position];
  }

  void clear() {
    position = 0;
  }
}