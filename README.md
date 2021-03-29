# awkward

Read the Word of God from your terminal

## Usage

    usage: awkward [flags] [reference...]

      -e    encrypt awkward for redistribution
      -l    list books
      -L    print license
      -h    show help
      -W    no line wrap

      Reference types:
          <Book>
              Individual book
          <Book>:<Chapter>
              Individual chapter of a book
          <Book>:<Chapter>:<Verse>[,<Verse>]...
              Individual verse(s) of a specific chapter of a book
          <Book>:<Chapter>-<Chapter>
              Range of chapters in a book
          <Book>:<Chapter>:<Verse>-<Verse>
              Range of verses in a book chapter
          <Book>:<Chapter>:<Verse>-<Chapter>:<Verse>
              Range of chapters and verses in a book

          /<Search>
              All verses that match a pattern
          <Book>/<Search>
              All verses in a book that match a pattern
          <Book>:<Chapter>/<Search>
              All verses in a chapter of a book that match a pattern

## Build

awkward can be built by cloning the repository and then running make:

    git clone https://github.com/gregcm/awkward.git
    cd awkward
    make

## License

(2021) Gregory Caceres-Munsell <gregcaceres@gmail.com>

Public domain

Adapted from https://github.com/bontibon/kjv.git
