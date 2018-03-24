module dsv.Parser;

import std.format;

import dsv.FieldState;
import dsv.InvalidFieldException;

class Parser
{
  /**
   * Size of reallocation steps.
   */
  private immutable int reallocStepSize;

  private immutable char textDelimiter;
  private immutable char fieldDelimiter;

  private FieldState fieldState;

  /**
   * Total number of columns per row
   *
   * Value is used to pre-allocate each row to avoid repeated reallocations as
   * fields are parsed.
   */
  private int totalColumns;

  /**
   * Parsed Rows/Columns
   */
  private string[][] values;

  /**
   * Current row index
   */
  private int row;

  /**
   * Current column index
   */
  private int col;

  /**
   * Current field buffer
   */
  private string fieldBuf;

  /**
   * Current character from input
   */
  private char current;

  /**
   * Next character from input
   */
  private char next;

  /**
   * Index of current character from input
   */
  private int  inputIndex;

  this(
    immutable int stepSize,
    immutable char textDelimiter,
    immutable char fieldDelimiter
  ) {
    this.fieldState = FieldState.START;
    this.values.length = stepSize;
    this.reallocStepSize = stepSize;
    this.fieldDelimiter = fieldDelimiter;
    this.textDelimiter = textDelimiter;
    this.col = -1;
  }

  public void parse(const char[] input) {
    for(inputIndex = 0; inputIndex < input.length; inputIndex++) {
      current = input[inputIndex];
      next    = inputIndex + 1 == input.length ? '\0' : input[inputIndex + 1];

      if (current == fieldDelimiter) {
        handleFieldDelimiter();
      } else if (current == textDelimiter) {
        handleTextDelimiter();
      } else if (current == '\n') {
        handleLineFeed();
      } else if (current == '\r') {
        handleCarriageReturn();
      } else {
        handleDefault();
      }
    }
  }

  public string[][] finish() {
    if (fieldBuf.length > 0) {
      appendField();
    }
    return this.values[0..row+1].dup;
  }

  private void handleDefault() {
    if (fieldState == FieldState.CLOSED) {
      throw new InvalidFieldException(
        format!"Improperly text delimited field at: row %d, col %d "(row + 1, col + 2)
      );
    }

    if (fieldState == FieldState.START) {
      fieldState = FieldState.PROCESSING;
    }

    fieldBuf ~= current;
  }

  private void handleCarriageReturn() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuf ~= current;
      return;
    }

    if (next == '\n')
      inputIndex++;

    handleLineFeed();
  }

  private void handleLineFeed() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuf ~= current;
      return;
    }
    if (col > -1) {
      if (fieldState != FieldState.START)
        appendField();
      stepRow();
    }
  }

  private void handleFieldDelimiter() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuf ~= fieldDelimiter;
      return;
    }
    appendField();
  }

  private void handleTextDelimiter() {
    if (fieldState == FieldState.START) {
      fieldState = FieldState.QUOTED;
      return;
    }

    if (fieldState == FieldState.QUOTED) {
      if (next == current) {
        inputIndex++;
        fieldBuf ~= current;
      } else {
        fieldState = FieldState.CLOSED;
      }
      return;
    }

    throw new InvalidFieldException(
      format!"Improperly text delimited field at: row %d, col %d "(row + 1, col + 2)
    );
  }

  /**
   * Shift Row Index
   *
   * Performs the following steps:
   *   - Increments the current row index
   *   - Resizes the row array if needed
   *   - Resets the column index
   */
  private void stepRow() {
    row++;
    while(row >= values.length)
      values.length += reallocStepSize;
    col = -1;
  }

  /**
   * Shift Column Index
   *
   * Performs the following steps:
   *   - Increments the current column index
   *   - Resizes the total column count if needed
   */
  private void stepColumn() {
    col++;
    immutable int tmp = col + 1;
    while (tmp > totalColumns)
      totalColumns++;
    resizeColumn();
  }

  private void resizeColumn() {
    if (values[row].length < totalColumns)
      values[row].length = totalColumns;
  }

  private void appendField() {
    stepColumn();
    values[row][col] = fieldBuf;
    fieldBuf = "";
    fieldState = FieldState.START;
  }
}
