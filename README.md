# stikkitsh

Query stikkit from the commandline.

## Usage

  ruby stikkit.rb [ -h | --help ] [ -l | --list type parameters ] [ -t | --todos ] [ -c | --create text ]
  type::
    The type of stikkit to return (todos, calendar, etc.)
  parameters::
    Specify restrictions on the stikkits returned (e.g. 'dates=this+week')
  text::
    Content of the new stikkit

So, we can get today's events with:
  ruby stikkit.rb -l calendar dates=today

--todos is a convenience method to get undone todos
which is equivalent to:
  ruby stikkit.rb -l todos done=0

Create a new stikkit:
  ruby stikkit.rb -c 'Remember this text.'

## Installation

Your username and password are stored in ~/.stikkit as a YAML file
    ---
    username: me@domain.org
    password: superSecret
