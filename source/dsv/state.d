module dsv.state;

enum ParserState {
  // Parser has not yet encountered data
  NONE,

  // Parser is reading an unquoted field
  TEXT,

  // Parser has encountered a quote while in a quoted field
  MID_QUOTE,

  // Parser is reading a quoted field
  QUOTED_TEXT,

  // Parser has encountered a line break
  ROW_BREAK,

  // Parser has encountered a field delimiter
  DELIM,
}
