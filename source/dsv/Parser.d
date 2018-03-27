module dsv.Parser;

import std.format;
import std.array;

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

  private int curRowIndex;

  private int curColIndex;

  private Appender!(char[]) fieldBuffer;

  private char currentChar;

  private char nextChar;

  /**
   * Index of current character from input
   */
  private int  inputIndex;

  private bool needRow;

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
    this.fieldBuffer = appender!(char[]);
    this.needRow = false;
    this.curColIndex = -1;
  }

  public void parse(const char[] input) {
    for(inputIndex = 0; inputIndex < input.length; inputIndex++) {
      currentChar = input[inputIndex];
      nextChar    = inputIndex + 1 == input.length ? '\0' : input[inputIndex + 1];

      if (currentChar == fieldDelimiter) {
        handleFieldDelimiter();
      } else if (currentChar == textDelimiter) {
        handleTextDelimiter();
      } else if (currentChar == '\n') {
        handleLineFeed();
      } else if (currentChar == '\r') {
        handleCarriageReturn();
      } else {
        handleDefault();
      }
    }
  }

  public string[][] finish() {
    if (fieldState != FieldState.START) {
      step();
    }
    return this.values[0..curRowIndex+1].dup;
  }

  private void handleDefault() {
    if (fieldState == FieldState.CLOSED) {
      throw new InvalidFieldException(curRowIndex, curColIndex);
    }

    if (fieldState == FieldState.START) {
      fieldState = FieldState.PROCESSING;
    }

    fieldBuffer.put(currentChar);
  }

  private void handleCarriageReturn() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuffer.put(currentChar);
      return;
    }

    if (nextChar == '\n')
      inputIndex++;

    handleLineFeed();
  }

  private void handleLineFeed() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuffer.put(currentChar);
      return;
    }
    if (curColIndex > -1 || fieldState != FieldState.START) {
      if (fieldState != FieldState.START)
        step();
      needRow = true;
    }
  }

  private void handleFieldDelimiter() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuffer.put(fieldDelimiter);
      return;
    }
    step();
  }

  private void handleTextDelimiter() {
    if (fieldState == FieldState.START) {
      fieldState = FieldState.QUOTED;
      return;
    }

    if (fieldState == FieldState.QUOTED) {
      if (nextChar == currentChar) {
        inputIndex++;
        fieldBuffer.put(currentChar);
      } else {
        fieldState = FieldState.CLOSED;
      }
      return;
    }

    throw new InvalidFieldException(curRowIndex, curColIndex);
  }

  private void stepRow() {
    if (!needRow)
      return;

    curRowIndex++;

    while(curRowIndex >= values.length)
      values.length += reallocStepSize;

    curColIndex = -1;
    needRow = false;
  }

  private void stepColumn() {
    curColIndex++;
    immutable int tmp = curColIndex + 1;
    if (tmp > totalColumns)
      totalColumns = tmp;
    resizeColumn();
  }

  private void resizeColumn() {
    if (values[curRowIndex].length < totalColumns)
      for (int i; i <= curRowIndex; i++)
        values[i].length = totalColumns;
  }

  private void step() {
    stepRow();
    stepColumn();
    pushBuffer();
  }

  private void pushBuffer() {
    values[curRowIndex][curColIndex] = fieldBuffer.data().dup();
    fieldBuffer.clear;
    fieldState = FieldState.START;
  }
}
