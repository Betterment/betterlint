# Betterlint

Shared rubocop configuration for Betterment Rails apps/engines.

Check out the [styleguide](STYLEGUIDE.md) for some additional commentary on our cop configurations.

## Installation

Gemfile:

```ruby
gem 'betterlint'
```

.rubocop.yml:

```yml
inherit_gem:
  betterlint:
    - config/default.yml
```

## Dependencies

This gem depends on the following other gems:

- rubocop
- rubocop-rspec

## Custom Cops

All cops are located under [`lib/rubocop/cop/betterment`](lib/rubocop/cop/betterment)

### Betterment/AuthorizationInController

This cop looks for unsafe handling of id-like parameters in controllers that may lead to [insecure direct object reference vulnerabilities](https://portswigger.net/web-security/access-control/idor). It does this by tracking methods that retrieve input from the client and variables that hold onto these values. Any models initialized or updated using these values will then be flagged by the cop. Take this example controller:

```ruby
class Controller
  def create_params
    params.permit(:user_id, :language)
  end

  def create
    info = params.permit(:user_id)
    Model.new(user_id: info[:user_id], language: params[:language])
    Model.new(user_id: params[:user_id], language: params[:language])
    Model.new(create_params)
  end
end
```

All three `Model.new` calls may be susceptible to an insecure direct object reference vulnerability. This may end up letting attackers read and write content belonging to other users. To address these vulnerabilities, some form of authorization will be needed to ensure that the user issuing this request is allowed to create a `Model` that references the specific `user_id`. To get a better understanding of what this cop flags and doesn't flag, take a look at its [spec](spec/rubocop/cop/betterment/authorization_in_controller_spec.rb).

In cases where more fine-grained control over what parameters are considered sensitive is desired, two configuration options can be used: `unsafe_parameters` and `unsafe_regex`. By default this cop will flag unsafe uses of any parameters whose names end in `_id`, but additional parameters can be specified by configuring `unsafe_parameters`. In cases where the default pattern of `.*_id` is insufficient or incorrect, this regex can be swapped out by specifying the `unsafe_regex` configuration option. In total, this cop will flag any parameters whose names are on the `unsafe_parameters` list or matches the `unsafe_regex` pattern.

This is what a full configuration of this cop may look like:

```yaml
Betterment/AuthorizationInController:
  # Limit this cop just to controllers
  Include:
    - 'app/controllers/**/*.rb'
  unsafe_parameters:
    - username
    - misc_unsafe_parameter
  unsafe_regex: '.*_id$'
```

### Betterment/UnscopedFind

This cop flags code that passes user input directly into a `find`-like call that may lead to authorization issues (such as [indirect object reference vulnerabilities](https://portswigger.net/web-security/access-control/idor)). For example, a controller that uses user input to find a document will need to ensure that the user is authorized to access that document. Take the following sample:

```ruby
class Controller
  def index
    @document = Document.find(params[:document_id])
  end
end
```

In this case, `@document` may not belong to the user and authorization will have to be done somewhere else, potentially introducing a vulnerability. One way to address this violation is to replace the `Document.find(...)` call with a `current_user.documents.find(...)` call. This fails fast when `current_user` is not authorized to access the document, without an extra authorization check that a `Document.find` call would require.

When dealing with models whose data is not ever considered private, it may make sense to add them to the `unauthenticated_models` configuration option. For example, reference data such as `ZipCode` or `Language` may be represented using models, but may not make sense to enforce any form of authentication. Take the sample controller below:

```ruby
class Controller < UnauthenticatedWebappController
  def index
    @language = Language.find(params[:language])
    @zip = ZipCode.find(params[:zip])
  end
end
```

There is nothing specific to a user or otherwise anything sensitive about `Language` or `ZipCode`. The cop can be configured to treat these models as unauthenticated so that calling `find`-like methods with them will not trigger any violations:

```yaml
Betterment/UnscopedFind:
  unauthenticated_models:
    - Language
    - ZipCode
```

### Betterment/DirectDelayedEnqueue

This cop flags code that uses `Object#delay` or `Delayed::Job.enqueue`. Please use `ActiveJob` instead.

```ruby
user.delay.save!
Delayed::Job.enqueue(MyJob.new)
```

### Betterment/DynamicParams

This cop flags code that accesses parameters whose names may be dynamically generated, such as a list of parameters in an a global variable or a return value from a method. In some cases, dynamically accessing parameter names can obscure what the client is expected to send and may make it difficult to reason about the code, both manually and programmatically. For example:

```ruby
class Controller
  def create_param_names
    %i(user_id first_name last_name)
  end

  def create
    parameter_name = :user_id
    params.permit(parameter_name)
    params.permit(create_params_names)
    params.permit(%w(blog post comment).flat_map { |p| ["#{p}_name", "#{p}_title"] })
  end
end
```

All three `params.permit` calls will be flagged.

### Betterment/EnvironmentConfiguration

This cop identifies references to `ENV` outside of the config directory.

Environment variables should be parsed at boot time. If an environment variable is missing or invalid,
the application should fail to boot.

If there isn't a better place to assign your environment variable, Rails provides the `config.x` namespace
for [custom configuration](https://guides.rubyonrails.org/configuring.html#custom-configuration):

```ruby
config.x.whatever = ENV.fetch('WHATEVER')
```

Here's how you'd reference this configuration parameter at runtime:

```ruby
Rails.configuration.x.whatever
```

### Betterment/InternalsProtection

This cop is not enabled by default, and must be enabled from your `.rubocop.yml` file:

```yaml
Betterment/InternalsProtection:
  Enabled: true
```

This cop enforces constants defined within `Internals` modules from being referenced from other modules.

For example, if you have a `Widget` ActiveRecord class that you don't want to be used directly,
you can place it into an Internals module such as:
```ruby
class Widgets::Internals::Widget < ApplicationRecord
end
```

Code outside of the `Widgets` module will not be allowed to reference Widget:
```ruby
class WidgetsController < ApplicationController
  def create
    Widgets::Internals::Widget.create!
    ^^^^^^^^^^^^^^^^^^ Internal constants may only be referenced from code within its containing module. [...]
  end
end
```

Non-Internal code within the module can be used to manage access.
```ruby
class Widgets::WidgetCreation
  def save!
    Widgets::Internals::Widget.create!
  end
end

class WidgetsController < ApplicationController
  def create
    Widgets::WidgetCreation.new.save!
  end
end
```

This cop inspects all direct constant references, and the `class_name` attribute on ActiveRecord associations.

### Betterment/UnsafeJob

This cop flags delayed jobs (e.g. ActiveJob, delayed_job) whose classes accept sensitive data via a `perform` or `initialize` method. Jobs are serialized in plaintext, so any sensitive data they accept will be accessible in plaintext to everyone with database access. Instead, consider passing ActiveRecord instances that appropriately handle sensitive data (e.g. encrypted at rest and decrypted when the data is needed) or avoid passing in this data entirely.

```ruby
class RegistrationJob < ApplicationJob
  def perform(user:, password:, authorization_token:)
    # do something to the user with the password and authorization_token
  end
end
```

When a `RegistrationJob` gets queued, this job will get serialized, leaving both `password` and `authorization_token` accessible in plaintext. `Betterment/UnsafeJob` can be configured to flag parameters like these to discourage their use. Some ways to remediate this might be to stop passing in `password`, and to encrypt `authorization_token` and storing it alongside the user object. For example:

```ruby
class RegistrationJob < ApplicationJob
  def perform(user:)
    authorization_token = user.authorization_token.decrypt
    # do something with the authorization_token
  end
end
```

By default, this job will look at classes whose name ends with `Job` but this can be replaced with any regex. This cop can also be configured to take an arbitrary list of parameter names so that any Job found accepting these parameters will be flagged.

```yaml
Betterment/UnsafeJob:
  class_regex: .*Job$
  sensitive_params:
    - password
    - authorization_token
```

It may make sense to consult your application's values for `Rails.application.config.filter_parameters`; if the application is filtering specific parameters from being logged, it might be a good idea to prevent these values from being stored in plaintext in a database as well.

### Betterment/NonStandardActions

This cop looks at Rails route files and flags routes that go to non-standard controller actions.
The 7 standard controller actions (index, show, new, edit, create, update, destroy) are well defined,
which allow for policies and middleware that can be applied to any controller.
For example, if we want a user role to only be able to view but not modify,
we can blanket deny access to create, update, and destroy actions and have it work in most use cases.

Custom actions require explicit configuration to work with these sorts of middleware,
so we prefer to use new controllers instead. For example, a resourceful route with a custom action like this:

```ruby
Rails.application.routes.draw do
  resources :alerts, only: [:index, :summary]
end
```

This can instead by written with an additional controller:

```ruby
Rails.application.routes.draw do
  resources :alerts, only: :index # AlertsController#index
  namespace :alerts do
    resource :summary, only: :show #Alerts::SummariesController#show
  end
end
```

By default this will look only in `config/routes.rb` and will use the standard 7 actions.
These values can be configured:

```yaml
Betterment/NonStandardActions:
  AdditionalAllowedActions:
    - update_all
    - destroy_all
  Include:
    - 'config/routes.rb'
    - 'config/other_routes.rb'
```

### Betterment/HardcodedID

This cop identifies hardcoded IDs in your specs. You should not hardcode IDs in specs because the spec may flake due to an ID collision, leading to false positives, unique constraint violations (e.g. `PG::UniqueViolation`), and more.

Instead of hardcoding an ID, create the resource and reference its ID. If the ID refers to an identifier in an external system, consider using a [FactoryBot sequence](https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#sequences).

This cop is capable of autocorrecting offenses, but it's not entirely safe. If you want to opt-in, add the following config to your `rubocop.yml` and run with `rubocop -A`:

```yaml
Betterment/HardcodedID:
  AutoCorrect: true
```

### Betterment/RedirectStatus

The `redirect_to` method defaults to a `302 Found`, but when redirecting a POST/PUT/PATCH/DELETE
to a GET location, the correct response code is `303 See Other`.

This cop requires you to explictly provide an HTTP status code when redirecting from the create,
update, and destory actions. When autocorrecting, this will automatically add `status: :see_other`.

### Betterment/RenderStatus

The `render` method defaults to a `200 OK`. Calling `render` in the create, update, and destroy
actions often indicates error handling (e.g. `422 Unprocessable Entity`).

This cop requires you to explicitly provide an HTTP status code when rendering a response in the
create, update, and destroy actions. When autocorrecting, this will automatically add
`status: :unprocessable_entity` or `status: :ok` depending on what you're rendering.

### Betterment/UseGlobalStrictLoading/ByDefaultForModels

This cop identifies models where `self.strict_loading_by_default` is assigned to explicitly, and prefers that it be removed in favor of using the global strict loading settings.

We use this to create a `.rubocop_todo.yml` file showing all the models that have been explicitly configured, so that we can "burn down" and lean more heavily on using global settings. We prefer to enable strict loading by default globally, but transioning a large Rails application to work in that state is difficult and must be broken down into smaller steps. Our workflow is to change all models to turn off strict loading, regenerate our rubocop todo file, then enable the flag globally. Then on a model-by-model basis we'll enable them one at a time, and fix all spec failures per model.

This allows us two benefits:

1. We can gradually change code used by older models to use strict loading without having to fix the world all at once.
2. All new models will strict load by default, forcing us to specify the objcts to load up-front in our controllers and other call sites.

### Betterment/UseGlobalStrictLoading/ForAssociations

This cop identifies associations where `:strict_loading` is set explicitly, and prefers that it be removed in favor of using the global strict loading settings.

This is related to the [Betterment/UseGlobalStrictLoading/ByDefaultForModels](#bettermentuseglobalstrictloadingbydefaultformodels) cop, but allows for more granular enablement and disablement of associations within a model. The intention is similar, in that we are using this cop to help "burn down" code to strict load, but it allows us to focus on the per-association level. Some models may have quite a lot of usage, so enabling it for a model might cause thousands of failures in the specs. In those cases we will disable all the associations, and then work through them one at a time until all code that uses the model strict loads.

### Betterment/VagueSerialize

This cop identifies calls to `serialize` that do not specify a coder, either by using the positional argument or the `coder`
keyword argument.

**NOTE:** Using a positional argument is deprecated for Rails 7.1+. That means that...

- If you are on Rails 7.2
- And you've opted into 7.1 defaults (namely, `config.active_record.default_column_serializer = nil`)

...you can safely disable this cop, since failing to pass a deserializer will raise an exception.
