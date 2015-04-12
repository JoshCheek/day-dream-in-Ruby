Day Dream In Ruby
=================

Playing with the idea of transpiling into Ruby.
This is just an experiment, it is in no way intended to ever be legitimate.

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

It's a mediocre implementation, but I learned a lot while doing it.
Oh... currently, it doesn't actually work, either :P

To see what I had in mind, check `example/example_input.ddir`
and compare that to `example/example_output.ddir`

License
-------

You just do what the fuck you want to.

[http://www.wtfpl.net/about/](http://www.wtfpl.net/about/)
