module dsv.parse.headless;

import dsv.buffer;
import dsv.state;
import dsv.exception;

class HeadlessParser {

  private immutable char cellSep;

  private immutable char textSep;

  private Buffer!char cellBuf;

  private Buffer!(string[]) rowBuf;

  private string[] colBuf;

  private ParserState pState;

  private int curCol;

  public this(
    immutable char cellSep,
    immutable char textSep,
    immutable size_t buffStep
  ) {
    this.cellSep = cellSep;
    this.textSep = textSep;
    this.cellBuf = Buffer!char(buffStep);
    this.rowBuf = Buffer!(string[])(buffStep);
    this.pState = ParserState.NONE;
  }
  
  public void write(const char[] c) {
    for (size_t i; i < c.length; i++)
      write(c[i]);
  }

  public void write(immutable char c) {
    final switch(this.pState) {
      case ParserState.TEXT:        text(c);       break;
      case ParserState.QUOTED_TEXT: quotedText(c); break;
      case ParserState.DELIM:       delim(c);      break;
      case ParserState.MID_QUOTE:   midQuote(c);   break;
      case ParserState.ROW_BREAK:   rowBreak(c);   break;
      case ParserState.NONE:        none(c);       break;
    }
  }

  public string[][] read() {
    if (cellBuf.length > 0) {
      finishField;
    }
    if (curCol > 0) {
      finishRow;
    }
    return this.rowBuf.data.dup;
  }

  private void text(immutable char c) {
    if (c == this.cellSep) {
      finishField;
      pState = ParserState.DELIM;
    } else if (c == '\n' || c == '\r') {
      finishField;
      finishRow;
      pState = ParserState.ROW_BREAK;
    } else if (c == this.textSep) {
      throw new InvalidFieldException(
        curCol > 0 ? rowBuf.length : rowBuf.length + 1,
        curCol
      );
    } else {
      cellBuf.append(c);
    }
  }

  private void quotedText(immutable char c) {
    if (c == this.textSep) {
      pState = ParserState.MID_QUOTE;
    } else {
      cellBuf.append(c);
    }
  }

  private void delim(immutable char c) {
    if (c == textSep) {
      pState = ParserState.QUOTED_TEXT;
    } else if (c == cellSep) {
      finishField;
    } else if (c == '\n' || c == '\r') {
      finishField;
      finishRow;
      pState = ParserState.ROW_BREAK;
    } else {
      cellBuf.append(c);
      pState = ParserState.TEXT;
    }
  }

  private void midQuote(immutable char c) {
    if (c == this.textSep) {
      this.cellBuf.append(c);
      this.pState = ParserState.QUOTED_TEXT;
    } else if (c == this.cellSep) {
      finishField;
      this.pState = ParserState.DELIM;
    } else if (c == '\n' || c == '\r') {
      finishField;
      finishRow;
      this.pState = ParserState.ROW_BREAK;
    }
  }

  private void rowBreak(immutable char c) {
    if (c == textSep) {
      pState = ParserState.QUOTED_TEXT;
    } else if (c == cellSep) {
      finishField;
      pState = ParserState.DELIM;
    } else if (c == '\n' || c == '\r') {
      // Do nothing for empty lines between rows
    } else {
      cellBuf.append(c);
      pState = ParserState.TEXT;
    }
  }

  private void none(immutable char c) {
    if (c == this.textSep) {
      pState = ParserState.QUOTED_TEXT;
    } else if (c == this.cellSep) {
      finishField;
      pState = ParserState.DELIM;
    } else if (c == '\n' || c == '\r') {
      // Ignore empty lines before content
    } else {
      cellBuf.append(c);
      pState = ParserState.TEXT;
    }
  }

  private void finishField() {
    const int tmp = curCol + 1;
    if (rowBuf.length == 0) {
      colBuf.length = tmp;
    } else if (tmp > colBuf.length) {
      throw new TooManyColumnsException(
        colBuf.length,
        tmp,
        rowBuf.length
      );
    }

    colBuf[curCol] = cellBuf.data.dup;
    curCol = tmp;
    cellBuf.clear;
  }

  private void finishRow() {
    for(size_t i = curCol; i < colBuf.length; i++)
      colBuf[i] = "";

    rowBuf.append(colBuf.dup);
    curCol = 0;
  }
}