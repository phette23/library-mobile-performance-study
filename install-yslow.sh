#! /usr/bin/env bash
git submodule init && git submodule update && cd yslow && make phantomjs && cd ..
