# MVC - Ruby/Sinatra/Sequel (Boilerplace/Stack)

This is a proposal to create a MVC project structure using [Ruby][1]
(programming language), [Sinatra][2] (DSL for web development) and [Sequel][3]
(O/RM and database toolkit). [Puma][4] is used as web server.

[1]: http://ruby-lang.org/
[2]: http://sinatrarb.com/
[3]: http://sequel.jeremyevans.net/
[4]: http://puma.io/

## Build new project

The following command should be run:

    $ bash project.sh <PROJECT_DIRNAME> <PROJECT_MODULE>

The old files will be saved with `.bkp` suffix and can cleaned using the
following command:

    $ make clean

## Common tasks

Run the following command to list the common tasks:

    $ make help
