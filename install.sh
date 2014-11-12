#!/usr/bin/env sh

here=$(pwd)
cd ~/

rm -rf swatted
git clone https://github.com/rgrannell1/swatted.git
echo alias swatted='ruby "~/swatted/lib/docopt-swatted.rb"' >> ~/.bashrc && . ~/.bashrc

cd $here
