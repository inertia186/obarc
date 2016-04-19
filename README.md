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

profile = session.profile
```
```json
{"profile":
  {"website": "website",
   "public_key": "b7d8f6ee04453e1babde87d12198ecd14be00aa998e85636767d8b00d2603e6d",
   .
   .
   .
   "primary_color": 16777215,
   "background_color": 12832757,
   "email": "email@bogus.com"}}
```
```ruby
session.update_profile(email: 'big@vendor.com')
```
```json
{"success": true}
```
```ruby
session.connected_peers
```
```json
{"peers": [["5.37.3.8", 28467]], "num_peers": 1}
```
```ruby
session.upload_image(image: 'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAC91JREFUWAktl3mQHOV5xn99zH3u7K1d7Uq7CEkIpNVZRhagQDjKCcaxSIJNIJTjI5XCuakKceXyHy5XnJSr')
```
```json
{"image_hashes": ["a89810619833ef29d373c124ce05f362a313929e"], "success": true}
```

## Get in touch!

If you're using OBarc, I'd love to hear from you.  Drop me a line and tell me what you think!

## Licence

I don't believe in intellectual "property".  If you do, consider OBarc as licensed under a Creative Commons [![CC0](http://i.creativecommons.org/p/zero/1.0/80x15.png)] (http://creativecommons.org/publicdomain/zero/1.0/) License.
