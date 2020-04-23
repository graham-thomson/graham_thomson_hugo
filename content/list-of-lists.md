---
title: "List of Lists"
date: 2019-06-18T21:17:24-04:00
draft: false
---

There are a seemingly infinite number of ways to flatten a list of lists in base Python. By flattening, I mean 
reducing the dimension of a list of lists. In numpy it would be something like:

```python
import numpy as np

np.arange(1, 13).reshape(4,3)
# array([[ 1,  2,  3],
#       [ 4,  5,  6],
#       [ 7,  8,  9],
#       [10, 11, 12]])

# becomes
np.arange(1, 13).reshape(4,3).reshape(-1)
# array([ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12])
```

But what is the fastest and cleanest way in base Python? If you've ever Googled this topic, you've likely come across 
[this StackOverflow post](https://stackoverflow.com/questions/952914/how-to-make-a-flat-list-out-of-list-of-lists) 
that was asked _10 years ago_ but has answers as new as last year (2018). 

So let's start by creating a small list of lists. 
```python
lol = [list(word) for word in "flatten this list of lists".split()]
"""
[['f', 'l', 'a', 't', 't', 'e', 'n'],
 ['t', 'h', 'i', 's'],
 ['l', 'i', 's', 't'],
 ['o', 'f'],
 ['l', 'i', 's', 't', 's']]
"""
```

Now, the novice way of doing this would be to instantiate a new empty list, then use a nested for loop to iterate
through the list of lists and append each string/character to the empty list. 

```python
empty_list = []
for sublist in lol:
    for char in sublist:
        empty_list.append(char)
# 2.61 µs ± 86.4 ns per loop (mean ± std. dev. of 7 runs, 100000 loops each)
```

Pretty from a readability standpoint but inefficient and pretty slow at 2.61 microseconds per loop.

Now we could do the same thing with a comprehension. A bit less readable but still requires no imports and is a bit
faster at 1.22 microseconds per loop. 
```python
[char for sublist in lol for char in sublist]
# 1.22 µs ± 23.5 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

For those of you who've been using Python for some time, may remember in Python2, reduce was a built in function. 
You could do things like sum the digits from 1 - 9 by doing: `reduce(lambda x, y: x + y, range(10))`. This was moved 
to the functools library in [PEP-3100](https://www.python.org/dev/peps/pep-3100/) 
because "a loop is more readable most of the times". While I agree in most cases, I believe flattening a list of lists
is one of the exceptions.

```python
# dont worry, when I was using timeit, I had the imports in separate cells as to not time the import statement
from functools import reduce
from operator import add

reduce(add, lol)
# 728 ns ± 17.2 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

That's it. All we're doing is using `add` in place of our own anonymous function (e.g. `lambda x, y: x + y`) and 
reducing our list of lists by adding together each of the elements to flatten it. Almost twice as fast as doing this 
via a list comprehension and very readable.

Another way is by using the [iconcat](https://docs.python.org/3/library/operator.html#operator.iconcat) operator and an
empty list. `iconcat` is functionally equivalent to doing `thing += other_thing` but does so 'in place'.

```python
from operator import iconcat

reduce(iconcat, lol, [])
# 681 ns ± 35.4 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

Slightly faster (at least at this scale of list size).

One last way is to use chain from itertools and unpack the list as arguments to chain. Like much of itertools, this
returns a generator so we must cast as a list if we want a list returned.

```python
from itertools import chain

list(chain(*lol))
# 910 ns ± 30.8 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

For even more detail including how these solutions scale as the size of the list of list gets bigger, 
go back to that StackOverflow post and check out 
[Nico Schlömer's](https://stackoverflow.com/users/353337/nico-schl%c3%b6mer) answer (it isn't the selected answer). 
He even provides this pretty time complexity graph:

[![image](https://i.stack.imgur.com/ZJrxd.png)](https://stackoverflow.com/questions/952914/how-to-make-a-flat-list-out-of-list-of-lists)


