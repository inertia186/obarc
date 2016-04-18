OpenBazaar API Ruby Client
==========================
 
[![Build Status](https://travis-ci.org/inertia186/obarc.svg?branch=master)](https://travis-ci.org/inertia186/obarc) [![Code Climate](https://codeclimate.com/github/inertia186/obarc/badges/gpa.svg)](https://codeclimate.com/github/inertia186/obarc) [![Test Coverage](https://codeclimate.com/github/inertia186/obarc/badges/coverage.svg)](https://codeclimate.com/github/inertia186/obarc)

A simple OpenBazaar API client for Ruby.

### Installation

Add the gem to your Gemfile:

    gem 'obarc', github: 'inertia186/obarc'
    
Then:

    $ bundle install

### Usage

```ruby
require 'obarc'

session = OBarc::Session.new(username: 'username', password: 'password')
```

## Get in touch!

If you're using OBarc, I'd love to hear from you.  Drop me a line and tell me what you think!

## Licence

I don't believe in intellectual "property".  If you do, consider OBarc as licensed under a Creative Commons [![CC0](http://i.creativecommons.org/p/zero/1.0/80x15.png)] (http://creativecommons.org/publicdomain/zero/1.0/) License.
