module dsv.ParserBuilder;

import dsv.Parser;

/**
 * Builder for configuring an instance of dsv.Parser
 */
class ParserBuilder {
  private int rss = 100;
  private char td = '"';
  private char fd = ',';

  /**
   * Set row array reallocation size.
   *
   * If/when the row array reaches its cap, the array size will be increased by
   * this amount.
   *
   * Used to tune array reallocation frequency.
   *
   * Default: `100`
   */
  public ParserBuilder reallocationStepSize(const int size) {
    rss = size;
    return this;
  }

  /**
   * Set input text delimiter.
   *
   * Default: `"`
   */
  public ParserBuilder textDelimiter(const char del) {
    td = del;
    return this;
  }

  /**
   * Set input field delimiter.
   *
   * Default: `,`
   */
  public ParserBuilder fieldDelimiter(const char del) {
    fd = del;
    return this;
  }

  /**
   * Construct a dsv.Parser instance with the chosen options.
   */
  public Parser build() {
    return new Parser(rss, td, fd);
  }
}
