TaskList
========

Code tasks are constructive comments in the code that are prefixed with a tag. Here are some examples of code tasks in ruby:

```
# TODO: This is a todo item that needs to be done urgently!
# BUG Something wrong is happening...
# NOTE - This method is used for a specific reason.
```

Obviously real code tasks are a lot more constructive than the examples I gave above.

TaskList parses code files and lists code tasks.

Installation
------------

TaskList is provided as a gem, so the installation process is as simple as this:

```
% [sudo] gem install task-list
```

> **Note**: `%` is the prompt and `sudo` (without the square brackets) is not needed if you use RVM.

Features
--------

As stated above, TaskList lists code tags that it finds in code passed to it. Here are the supported tags:

- `TODO`
- `FIXME`
- `NOTE`
- `BUG`
- `CHANGED`
- `OPTIMIZE`
- `XXX`
- `!!!`

Also, TaskList will ignore the files that are under certain directory like `log` or `coverage`. Finally, TaskList will ignore files with certain extensions like images and SQLite databases.

Usage
-----

The TaskList comes with a command-line script called `tl` which takes one argument and only one argument. This argument can be one of two things:

- a file
- a folder

If a file is passed, TaskList will parse this file (or any other file that contains the query) to find code tags. On the other hand, if a folder is passed, TaskList will recursively parse all the files under that folder (or any other directory that contains the query) to find code tags. Here are some examples:

```
% tl task-list.rb
% tl task-list/
% tl task-list/task-list.rb
% tl .
```

By default, the search path is the current directory. To change it, use the `-d` option (or its long version `--directory`):

```
% tl -d lib
% tl --directory ~/Projects/ruby/task-list
```

Other options are also available (e.g.: the `-t` option used to find tasks of a certain type). Use `tl -h` to find out about them.

Contributing
------------

1. Fork it.
2. Create a branch (git checkout -b awesome-feature)
3. Commit your changes (git commit -am "Add AWESOME feature")
4. Push to the branch (git push origin awesome-feature)
5. Open a [Pull Request](https://github.com/RobertAudi/task-list/pulls)

License
-------

The MIT License (MIT)

Copyright (c) 2014 Robert Audi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
