module dsv.exception;

import std.format;

class InvalidFieldException : Exception {
  this(
    const size_t row,
    const size_t col,
    const string file = __FILE__,
    const size_t line = __LINE__
  ) {
    super(format!"Invalid field: row %d, col %d"(row, col + 2), file, line);
  }
}

class TooManyColumnsException: Exception {
  this(
    const size_t expected,
    const size_t actual,
    const size_t row,
    const string file = __FILE__,
    const size_t line = __LINE__
  ) {
    super(format!"too many columns on row %d; expected %d, got %d"(row, expected, actual));
  }
}