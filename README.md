SemVersion
==========

SemVersion is a gem to help parse, validate, modify, and compare [Semantic Versions](http://semver.org).

Parsing
-------

Parsing is easy:

```ruby
v = SemVersion.new('1.2.3-pre.4+build.5')

v.major         # => 1
v.minor         # => 2
v.patch         # => 3

v.pre           # => 'pre.4'
v.prerelease    # => 'pre.4'
v.build         # => 'build.5'

v.to_s          # => '1.2.3-pre.4+build.5'
```

You can pass any valid semantic version string, as specified by [Semantic Versions](http://semver.org).
Invalid versions will raise an ArgumentError

Validating
----------

Validating is easier:

```ruby
SemVersion.valid?('1.2.3')          # => true
SemVersion.valid?('1.2')            # => false
SemVersion.valid?('1.2.3-pre.1')    # => true
SemVersion.valid?('1.2.3-pre.!')    # => false
```

And so on...

Modifying
---------

You can modify any part of a parsed version.
Invalid new values will raise an ArgumentError

```ruby
v = SemVersion.new('1.2.3')
v.major = 3
v.minor = 5
v.pre = 'pre.2'
v.build = 'build.x.7'

v.to_s                           # => '3.5.1-pre.2+build.x.7'

v.major = -1                     # => ArgumentError
v.major = 'a'                    # => ArgumentError
v.pre = 'a.!'                    # => ArgumentError
v.pre = '.a'                     # => ArgumentError
```

Comparing
---------

You can compare semantic versions using `<`, `>`, `<=`, `>=`, `==`, and `<=>`

```ruby
SemVersion.new('1.2.3') < SemVersion.new('1.2.2')                  # => true
SemVersion.new('1.2.3-pre.1') <= SemVersion.new('1.2.3-pre')       # => false
SemVersion.new('1.2.3+build.11') > SemVersion.new('1.2.3+build.2') # => true
```

Satisfying constraints
----------------------

You can see whether a semantic version satisfies a particular constraint.
Constraints are in the form `"<comparison> <version>"`, e.g. ">= 1.2.2", "= 1.0.0", or "~> 1.2".

When using the pessimistic operation, `~>`, versions may be specified in the form `"x.y"` or `"x.y.z"` (with `"~> x.y"` meaning `">= x.y.0" && "< x+1.0.0"`, and `"~> x.y.z"` meaning `">= x.y.z" && "< x.y+1.0"`).

```ruby
SemVersion.new('1.2.3').satisfies?('=> 1.2.2')       # => true
SemVersion.new('1.2.3-pre.1').satisfies?('>= 1.2.3') # => false
SemVersion.new('2.3.0').satisfies?('~> 2.2')         # => true
```