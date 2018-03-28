module dsv.exception;

import std.format;

class InvalidFieldException : Exception {
  this(
    const int row,
    const int col,
    const string file = __FILE__,
    const size_t line = __LINE__
  ) {
    super(format!"Invalid field: row %d, col %d"(row + 1, col + 2), file, line);
  }
}

class TooManyColumnsException: Exception {
  this(
    const int expected,
    const int actual,
    const int row,
    const string file = __FILE__,
    const size_t line = __LINE__
  ) {
    super(format!"too many columns on row %d; expected %d, got %d"(row + 1, expected, actual));
  }
}