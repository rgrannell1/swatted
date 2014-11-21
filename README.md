
# swatted v0.1.0

List all the bugs you've swatted since your last release.

<img src="example.gif">

Swatted can output recently closed issues in machine-consumable formats, or automatically draft your changelog for you.

## Installation

```bash
wget -q -O - https://raw.githubusercontent.com/rgrannell1/swatted/master/install.sh | bash
```

To upgrade run

```bash
here=$(pwd)
rm -rf swatted
git clone https://github.com/rgrannell1/swatted.git
```

## Usage

```bash
cd myRepo/
swatted
```

## Requirements

* Ubuntu or another Unix (tested on 14.04)
* Ruby 1.9
* [Rugged](https://github.com/libgit2/rugged) 
* [Github](https://github.com/peter-murach/github)

## Licence

The MIT License

Copyright (c) 2014 Ryan Grannell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Versioning

Versioning complies with the Semantic Versioning 2.0.0 standard.

http://semver.org/
