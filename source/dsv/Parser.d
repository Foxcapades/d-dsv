module dsv.Parser;

import std.format;
import std.array;

import dsv.FieldState;
import dsv.exception;
import dsv.buffer;

class Parser
{
  private immutable char textDelimiter;

  private immutable char fieldDelimiter;

  private FieldState fieldState;

  private int columnCount;

  private int curColIndex;

  private char currentChar;

  private char nextChar;

  /**
   * Index of current character from input
   */
  private int  inputIndex;

  private bool needRow;

  private Buffer!(string[]) rowBuffer;

  private Buffer!char fieldBuffer;

  this(
    immutable int stepSize,
    immutable char textDelimiter,
    immutable char fieldDelimiter
  ) {
    this.fieldState = FieldState.START;
    this.fieldDelimiter = fieldDelimiter;
    this.textDelimiter = textDelimiter;
    this.needRow = true;
    this.curColIndex = -1;
    this.rowBuffer = Buffer!(string[])(stepSize);
    this.fieldBuffer = Buffer!char(stepSize);
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

  public string[][] data() {
    if (fieldState != FieldState.START) {
      step();
    }
    return this.rowBuffer.data.dup;
  }

  private void handleDefault() {
    if (fieldState == FieldState.CLOSED) {
      throw new InvalidFieldException(rowBuffer.length, curColIndex);
    }

    if (fieldState == FieldState.START) {
      fieldState = FieldState.PROCESSING;
    }

    fieldBuffer.append(currentChar);
  }

  private void handleCarriageReturn() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuffer.append(currentChar);
      return;
    }

    if (nextChar == '\n')
      inputIndex++;

    handleLineFeed();
  }

  private void handleLineFeed() {
    if (fieldState == FieldState.QUOTED) {
      fieldBuffer.append(currentChar);
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
      fieldBuffer.append(fieldDelimiter);
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
        fieldBuffer.append(currentChar);
      } else {
        fieldState = FieldState.CLOSED;
      }
      return;
    }

    throw new InvalidFieldException(rowBuffer.length, curColIndex);
  }

  private void stepRow() {
    if (!needRow)
      return;

    string[] tmp;
    tmp.length = columnCount;
    rowBuffer.append(tmp);

    curColIndex = -1;
    needRow = false;
  }

  private void stepColumn() {
    curColIndex++;
    if (rowBuffer.length == 1) {
      const int tmp = curColIndex + 1;
      rowBuffer.data[0].length = tmp;
      columnCount = tmp;
    } else if (curColIndex >= columnCount) {
      throw new TooManyColumnsException(
        columnCount,
        curColIndex + 1,
        rowBuffer.length
      );
    }
  }

  private void step() {
    stepRow();
    stepColumn();
    pushBuffer();
  }

  private void pushBuffer() {
    rowBuffer.get(rowBuffer.length - 1)[curColIndex] = fieldBuffer.data.dup;
    fieldBuffer.clear;
    fieldState = FieldState.START;
  }
}
