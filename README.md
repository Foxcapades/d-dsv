# D-DSV

Toy implementation of a simplistic delimiter separated value parser library in
D.  Made for the purpose of getting familiar with D as a language.

## Usage

### Sample Input

_test.tsv_
```csv

"hello"	goodbye
"line
	""breaks"""

foo	bar
	"fizz"

```

_test.d_
```d
import std.stdio;
import dsv;

void main(string[] args) {
  char[6] buffer;
  Parser tsv = new ParserBuilder().fieldDelimiter('\t').build();
  char[] tmp;

  do {
    tmp = stdin.rawRead(buffer);
    tsv.parse(tmp);
  } while (tmp.length == buffer.length);

  writeln(tsv.data);
}
```

```bash
$ cat test.csv | dub run
[["hello", "goodbye"], ["line\n\t\"breaks\"", ""], ["foo", "bar"], ["", "fizz"]]
```

### TODO

* Handle headers
  Current implementation treats headers as regular text
* Clean up `dsv.Parser` implementation
  'cause damn
