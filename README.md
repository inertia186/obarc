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
If you want to manually upload an image, this will return the image hash.
```ruby
session.upload_image(image: 'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAC91JREFUWAktl3mQHOV5xn99zH3u7K1d7Uq7CEkIpNVZRhagQDjKCcaxSIJNIJTjI5XCuakKceXyHy5XnJSr')
```
```json
{"image_hashes": ["a89810619833ef29d373c124ce05f362a313929e"], "success": true}
```
You can also add a new listing with image URLs in the hash.  The client will upload them and save the image hashes to the contract.
```ruby
session.add_contract(
  expiration_date: '',
  metadata_category: 'physical good',
  title: 'Black Dress',
  description: 'A pretty black dress.',
  currency_code: 'USD',
  price: '19.95',
  process_time: '3 Business Days',
  nsfw: 'false',
  shipping_origin: 'UNITED_STATES',
  ships_to: 'UNITED_STATES',
  est_delivery_domestic: '5-7 Business Days',
  est_delivery_international: '',
  terms_conditions: "We cannot ship to PO Boxes/APO's\n * We cannot combine shipping.\n * No Local Pickup.",
  returns: "Your satisfaction is guaranteed! If for any reason you are unhappy with your item, we can arrange a return within 14 days for a full refund, minus shipping cost. Please contact us prior to initiating a return so that we can issue you a refund authorization.",
  shipping_currency_code: 'USD',
  shipping_domestic: true,
  shipping_international: false,
  keywords: 'dress',
  category: '',
  condition: 'New',
  sku: '123456789',
  image_urls: ['http://i.imgur.com/2KXXHSt.jpg'],
  free_shipping: true
)
```
```json
{"success": true}
```
## Docmentation
  * [Session](http://www.rubydoc.info/github/inertia186/obarc/master/OBarc/Session) - Most of what you need in your app is explained here.

## Get in touch!

If you're using OBarc, I'd love to hear from you.  Drop me a line and tell me what you think!

## Licence

I don't believe in intellectual "property".  If you do, consider OBarc as licensed under a Creative Commons [![CC0](http://i.creativecommons.org/p/zero/1.0/80x15.png)] (http://creativecommons.org/publicdomain/zero/1.0/) License.
