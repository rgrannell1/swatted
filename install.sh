#!/usr/bin/env sh

here=$(pwd)
rm -rf swatted
git clone https://github.com/rgrannell1/swatted.git
cd swatted
echo alias swatted=\'$(pwd -P)/lib/docopt-swatted.rb\' >> ~/.bashrc && . ~/.bashrc
cd $here
