#!/usr/bin/env bash

mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
if [ -f "~/.vimrc" ]; then
   cp "~/.vimrc" "~/.vimrc_original"
   echo "execute pathogen#infect()" >> ~/.vimrc 
fi

