module dsv.parse.parser;

import dsv.buffer;
import dsv.state;
import dsv.exception;

interface Parser(T) {
  public void write(const char[] c);

  public void write(immutable char c);

  public T[] read();
}