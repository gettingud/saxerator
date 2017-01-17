Saxerator [![Build Status](https://secure.travis-ci.org/soulcutter/saxerator.png?branch=master)](http://travis-ci.org/soulcutter/saxerator) [![Code Climate](https://codeclimate.com/github/soulcutter/saxerator.png)](https://codeclimate.com/github/soulcutter/saxerator)
=========

Saxerator is a streaming xml-to-hash parser designed for working with very large xml files by
giving you Enumerable access to manageable chunks of the document.

Each xml chunk is parsed into a JSON-like Ruby Hash structure for consumption.

You can parse any valid xml in 3 simple steps.

1. Initialize the parser
1. Specify which tag you care about using a simple DSL
1. Perform your work in an `each` block, or using any [Enumerable](http://apidock.com/ruby/Enumerable)
method

Installation
------------
1. `gem install saxerator`
1. Choose an xml parser
    * `gem install nokogiri` (this is the default)
    * `gem install ox`
1. If not using the default, specify your adapter in the [Saxerator configuration](#configuration)

:boom: BREAKING CHANGES :boom:
----------------

In new version for `output_type = :xml` Saxerator returns a `REXML::Document`
You could find details on paragraph below

The DSL
-------
The DSL consists of predicates that may be combined to describe which elements the parser should enumerate over.
Saxerator will only enumerate over chunks of xml that match all of the combined predicates (see Examples section
for added clarity).

| Predicate        | Explanation |
|:-----------------|:------------|
| `all`            | Returns the entire document parsed into a hash. Cannot combine with other predicates
| `for_tag(name)`  | Elements whose name matches the given `name`
| `for_tags(names)`| Elements whose name is in the `names` Array
| `at_depth(n)`    | Elements `n` levels deep inside the root of an xml document. The root element itself is `n = 0`
| `within(name)`   | Elements nested anywhere within an element with the given `name`
| `child_of(name)` | Elements that are direct children of an element with the given `name`
| `with_attribute(name, value)` | Elements that have an attribute with a given `name` and `value`. If no `value` is given, matches any element with the specified attribute name present
| `with_attributes(attrs)` | Similar to `with_attribute` except takes an Array or Hash indicating the attributes to match

Examples
--------
```ruby
parser = Saxerator.parser(File.new("rss.xml"))

parser.for_tag(:item).each do |item|
  # where the xml contains <item><title>...</title><author>...</author></item>
  # item will look like {'title' => '...', 'author' => '...'}
  puts "#{item['title']}: #{item['author']}"
end

# a String is returned here since the given element contains only character data
puts "First title: #{parser.for_tag(:title).first}"
```

Attributes are stored as a part of the Hash or String object they relate to

```ruby
# author is a String here, but also responds to .attributes
primary_authors = parser.for_tag(:author).select { |author| author.attributes['type'] == 'primary' }
```

You can combine predicates to isolate just the tags you want.

```ruby
require 'saxerator'

parser = Saxerator.parser(bookshelf_xml)

# You can chain predicates
parser.for_tag(:name).within(:book).each { |book_name| puts book_name }

# You can re-use intermediary predicates
bookshelf_contents = parser.within(:bookshelf)

books = bookshelf_contents.for_tag(:book)
magazines = bookshelf_contents.for_tag(:magazine)

books.each do |book|
  # ...
end

magazines.each do |magazine|
  # ...
end
```

Configuration
-------------

Certain options are available via a configuration block at parser initialization.

```ruby
Saxerator.parser(xml) do |config|
  config.output_type = :xml
end
```

| Setting           | Default | Values          | Description
|:------------------|:--------|-----------------|------------
| `adapter`         | `:nokogiri` | `:nokogiri`, `:ox` | The XML parser used by Saxerator |
| `output_type`     | `:hash` | `:hash`, `:xml` | The type of object generated by Saxerator's parsing. `:hash` should be self-explanatory, `:xml` generates a `REXML::Document`
| `symbolize_keys!` | n/a     | n/a             | Call this method if you want the hash keys to be symbols rather than strings
| `ignore_namespaces!`| n/a   | n/a             | Call this method if you want to treat the XML document as if it has no namespace information. It differs slightly from `strip_namespaces!` since it deals with how the XML is processed rather than how it is output
| `strip_namespaces!`| n/a     | user-specified  | Called with no arguments this strips all namespaces, or you may specify an arbitrary number of namespaces to strip, i.e. `config.strip_namespaces! :rss, :soapenv`
| `put_attributes_in_hash!` | n/a     | n/a             | Call this method if you want xml attributes included as elements of the output hash - only valid with `output_type = :hash`

REXML
-----
  For `output_type = :xml` Saxerator returns a `REXML::Document`
  Documentation about it you could find here: [REXML::Document](http://ruby-doc.org/stdlib-2.4.0/libdoc/rexml/rdoc/REXML/Document.html)
  If you were using `xpath` for finding node take a look on [REXML::XPath](http://ruby-doc.org/stdlib-2.4.0/libdoc/rexml/rdoc/REXML/XPath.html)

Known Issues
------------
* JRuby closes the file stream at the end of parsing, therefor to perform multiple operations
  which parse a file you will need to instantiate a new parser with a new File object.

FAQ
---
Why the name 'Saxerator'?

  > It's a combination of SAX + Enumerator.

Why use Saxerator over regular SAX parsing?

  > Much of the SAX parsing code I've written over the years has fallen into a pattern that Saxerator encapsulates:
  > marshall a chunk of an XML document into an object, operate on that object, then move on to the
  > next chunk. Saxerator alleviates the pain of marshalling and allows you to focus solely on operating on the
  > document chunk.

Why not DOM parsing?

  > DOM parsers load the entire document into memory. Saxerator only holds a single chunk in memory at a time. If your
  > document is very large, this can be an important consideration.

When I fetch a tag that has one or more elements, sometimes I get an `Array`, and other times I get a `Hash` or `String`. Is there a way I can treat these consistently?

  > You can treat objects consistently as arrays using
  > [Ruby's built-in array conversion method](http://www.ruby-doc.org/core-2.1.1/Kernel.html#method-i-Array)
  > in the form `Array(element_or_array)`
  >
  > Generally you should not need to convert a parsed element to a `String` or `Hash`. One case it
  > occasionally comes up is for elements that are sometimes-empty. Empty elements behave mostly like an
  > empty `Hash`, however you may convert it to a more `String`-like object via `#to_s`

###  Contribution ###

For running tests for all parsers run `rake spec:adapters`

### Acknowledgements ###
Saxerator was inspired by - but not affiliated with - [nori](https://github.com/savonrb/nori) and [Gregory Brown](http://majesticseacreature.com/)'s
[Practicing Ruby](http://practicingruby.com/)

#### Legal Stuff ####
Copyright © Bradley Schaefer. MIT License (see LICENSE file).
