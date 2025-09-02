# Style Guide

## Block Delimeters for multi-line chaining

Prefer {...} over do...end for multi-line chained blocks.

We use the enforced style `braces_for_chaining`.

For example:

### BAD:

```ruby
array_of_things.each do |thing|
  thing if thing.condition?
end.compact
```

### GOOD:

```ruby
array_of_things.each { |thing|
  thing if thing.condition?
}.compact
```

## Timeout.timeout needs custom exception

If we use `Timeout.timeout` without a custom exception, rescue blocks may be prevented from executing.

For example:

### BAD:

```ruby
Timeout.timeout(run_timeout)
```

### GOOD:

```ruby
Timeout.timeout(run_timeout, SomeModule::SomeError)
```

## Rails/OutputSafety

We explictly enabled the `Rails/OutputSafety` cop to ensure its usage. It prevents usage of `raw`, `html_safe`, or `safe_concat` unless they are explicitly disabled.

This [blog post](https://engineering.betterment.qa/2017/05/15/unsafe-html-rendering.html) explains our feelings on unsafe HTML rendering.

## Use parentheses for percent literal delimeters

We enforce usage of parentheses for all percent literal delimeters besides `%r` (the macro for regexps) for which we use curly braces.

### GOOD:

```ruby
%w(one two three)
%i(one two three)
%r{(\w+)-(\d+)}
```

### BAD:

```ruby
%w[one two three]
%i[one two three]
%w!one two three!
%r((\w+)-(\d+))
```

## Naming/VariableNumber

We enforce the style "snake_case", which means that we prefer to name variables that end in a number with an extra underscore.

### GOOD:

```ruby
user_1 = User.first
user_2 = User.second
```

### BAD:

```ruby
user1 = User.first
user2 = User.second
```

The snake case style is more readable.

## Betterment/ServerErrorAssertion

In RSpec tests, we prevent HTTP response status assertions against server error codes (e.g., 500). While it’s acceptable to
“under-build” APIs under assumption of controlled and well-behaving clients, these exceptions should be treated as undefined behavior and
thus do not need request spec coverage. In cases where the server must communicate an expected failure to the client, an appropriate
semantic status code must be used (e.g., 403, 422, etc.).

### GOOD:

```ruby
expect(response).to have_http_status :forbidden
expect(response).to have_http_status 422
```

### BAD:

```ruby
expect(response).to have_http_status :internal_server_error
expect(response).to have_http_status 500
```

## Betterment/SimpleDelegator

This cop requires you to use Rail's `delegate` class method instead of `SimpleDelegator` in order to explicitly specify
the set of delegating methods.

### BAD:

```ruby
class GearPresenter < SimpleDelegator
  def ratio_string
    ratio.to_s
  end
end
```

### GOOD:

```ruby
class GearDelegator
  attr_reader :gear

  delegate :ratio, to: :gear

  def initialize(gear)
    @gear = gear
  end

  def ratio_string
    ratio.to_s
  end
end
```
