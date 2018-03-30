module dsv.buffer;

struct Buffer(T) {
  private T[] buffer;

  private size_t position;

  private immutable size_t stepSize;

  this(immutable size_t stepSize) {
    this.buffer.length = stepSize;
    this.stepSize = stepSize;
  }

  void append(T row) {
    const size_t tmp = position + 1;
    if (tmp == buffer.length) {
      buffer.length += stepSize;
    }
    buffer[position] = row;
    position = tmp;
  }

  T get(immutable size_t i) {
    return buffer[i];
  }

  size_t length() {
    return position;
  }

  T[] data() {
    return buffer[0..position];
  }

  void clear() {
    position = 0;
  }
}