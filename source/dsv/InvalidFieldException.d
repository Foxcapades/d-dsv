module dsv.InvalidFieldException;

class InvalidFieldException : Exception {
  this(
    const string msg,
    const string file = __FILE__,
    const size_t line = __LINE__
  ) {
    super(msg, file, line);
  }
}
