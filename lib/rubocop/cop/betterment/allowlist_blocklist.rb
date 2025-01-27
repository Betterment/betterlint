# frozen_string_literal: true

# rubocop:disable Betterment/AllowlistBlocklist
module RuboCop
  module Cop
    module Betterment
      class AllowlistBlocklist < Base
        MSG = <<~DOC
          Avoid usages of whitelist & blacklist, in favor of more inclusive and descriptive language.
          For consistency, favor 'allowlist' and 'blocklist' where possible, but other terms (such as
          denylist, ignorelist, warnlist, safelist, etc) may be appropriate, depending on the use case.
        DOC

        def on_class(node)
          evaluate_node(node)
        end

        private

        def evaluate_node(node)
          return unless should_use_allowlist?(node) || should_use_blocklist?(node)

          add_offense(node)
        end

        def should_use_allowlist?(node)
          node.to_s.downcase.include?('whitelist')
        end

        def should_use_blocklist?(node)
          node.to_s.downcase.include?('blacklist')
        end
      end
    end
  end
end
# rubocop:enable Betterment/AllowlistBlocklist
