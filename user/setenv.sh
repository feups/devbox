#! /usr/bin/env bash
mkdir -p build
ghc --make ./user/setenv.hs -rtsopts -with-rtsopts=-I0 -outputdir=build/ -o build/build && build/build
