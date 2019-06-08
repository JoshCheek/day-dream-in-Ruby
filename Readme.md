Day Dream In Ruby
=================

Playing with the idea of transpiling into Ruby.
This is just a thought experiment, it is in no way intended to ever be legitimate.

Example
-------

```coffee
$ cat example/random_sentence.ddir
-> :random_char
  "a".upto "z"
     .to_a
     .sample

-> :random_word (max_length)
  @.rand max_length
    .times
    .map () @.random_char
    .join

-> :sentence (num_words, max_length)
  num_words
    .times
    .map () @.random_word max_length
    .reject (word.empty?)
    .join " "
    .capitalize
    << "."

num_words  <- 15
max_length <- 10
sentence   <- @.sentence num_words max_length
@.puts "Your sentence: " + sentence.inspect

$ bin/ddir example/random_sentence.ddir
Your sentence: "Flxytjvg eeakvl nssrspb ehlqlouvv xln jcipgbg milvqe lidrrkwt t yj kdmretzy in rgpqulii rlr."
```


Why?
-----

It's mostly just an idea that came to me after realizing
how hard it was to get my students to understand that the text in the Ruby file
doeesn't inherently mean anything.

I like to draw the Object model to illustrate what it's really doing,
but even that gives it a form that they begin to latch onto.
Thtat one's less problematic, because it's much much much closer to
the truth than what Ruby syntax would have you think.
But even then, once I get to explaining how module inclusion works,
it can't be represented without undermining the patterns of the drawing.
This shakes them up again!
They finally had nice concrete boxes and shit to latch onto.

So, I wanted to play with the idea of representing Ruby in a very different form.
Still the same language and underlying principles,
but in a way that might make it easier to get them to realize that Ruby isn't the syntax in their files,
but rather the memory structures and their relationships.


Running
-------

The example dir has a big [input file](https://github.com/JoshCheek/day-dream-in-Ruby/blob/master/example/input.ddir)
which can be compiled into the [output file](https://github.com/JoshCheek/day-dream-in-Ruby/blob/master/example/output.rb)
using `bin/ddir -s`

Run code in a file:

```sh
$ cat f.ddir
@.puts "hello world"

$ bin/ddir f.ddir
hello world
```

Get a list of options with:

```sh
bin/ddir -h
```

Run code from the console:

```sh
$ bin/ddir -e '@.puts "hello world"'
```


License
-------

You just do what the fuck you want to.

[http://www.wtfpl.net/about/](http://www.wtfpl.net/about/)
