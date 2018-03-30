# D-DSV

Toy implementation of a simplistic csv/tsv/*sv separated value parser library in
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
  char[5] buffer;
  HeadlessParser tsv = new HeadlessParser('\t', '"', 100);
  char[] tmp;

  do {
    tmp = stdin.rawRead(buffer);
    tsv.write(tmp);
  } while (tmp.length == buffer.length);

  writeln(tsv.read);
}
```

```bash
$ cat test.csv | dub run
[["hello", "goodbye"], ["line\n\t\"breaks\"", ""], ["foo", "bar"], ["", "fizz"]]
```

### TODO

* Handle headers