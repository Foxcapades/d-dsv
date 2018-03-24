# D-DSV

Toy implementation of a simplistic delimiter separated value parser library in
D.  Made for the purpose of getting familiar with D as a language.

## Features

* Input\
One or more lines/chunks of text.

* Output\
Currently parses input into a multi-dimensional array of strings.

* Controllable text delimiters\
Defaults to `"`

* Controllable field delimiters\
Defaults to `,`

## Usage

### Line by Line from stdin

```d
import std.stdio;
import dsv;

void main(string[] args){
  Parser tsv = new ParserBuilder().fieldDelimiter('\t').build();
  string line;

  while ((line = stdin.readln()) !is null)
    tsv.parse(line);

  writeln(tsv.finish());
}
```
```bash
$ echo -n "foo\tbar\tfoobar\r\n\"fizz\"\t\t\"buzz\"\rping\tpong\n\tcat\t\"dog\"" | dub run
[["foo", "bar", "foobar"], ["fizz", "", "buzz"], ["ping", "pong", ""], ["", "cat", "dog"]]
```

### Arbitrarily chunked input

```d
import std.stdio;
import dsv;

void main(string[] args){
  Parser tsv = new ParserBuilder().fieldDelimiter('\t').build();
  string line;

  tsv.parse("foo\tbar\tfoobar\r\n\"fi");
  tsv.parse("zz\"\t\t\"buzz\"");
  tsv.parse("\rping\tpong\n\tcat\t\"dog\"\n\n\n\n");

  writeln(tsv.finish());
}
```
```bash
$ dub run
[["foo", "bar", "foobar"], ["fizz", "", "buzz"], ["ping", "pong", ""], ["", "cat", "dog"]]
```

### TODO

* Handle headers
  Current implementation treats headers as regular text
* Reduce buffer reallocations::
  Field string buffer is reallocated per field character
* Clean up `dsv.Parser` implementation::
  'cause damn
