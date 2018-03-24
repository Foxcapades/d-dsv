module dsv.InvalidFieldException;

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
