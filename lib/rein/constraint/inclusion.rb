require 'rein/util'

module Rein
  module Constraint
    # This module contains methods for defining inclusion constraints.
    module Inclusion
      include ActiveRecord::ConnectionAdapters::Quoting

      def add_inclusion_constraint(*args)
        reversible do |dir|
          dir.up { _add_inclusion_constraint(*args) }
          dir.down { _remove_inclusion_constraint(*args) }
        end
      end

      def remove_inclusion_constraint(*args)
        reversible do |dir|
          dir.up { _remove_inclusion_constraint(*args) }
          dir.down { _add_inclusion_constraint(*args) }
        end
      end

      private

      def _add_inclusion_constraint(table, attribute, options = {})
        name = Util.constraint_name(table, attribute, 'inclusion', options)
        table = Util.wrap_identifier(table)
        values = options[:in].map { |value| quote(value) }.join(', ')
        attribute = Util.wrap_identifier(attribute)
        conditions = Util.conditions_with_if("#{attribute} IN (#{values})", options)
        execute("ALTER TABLE #{table} ADD CONSTRAINT #{name} CHECK (#{conditions})")
      end

      def _remove_inclusion_constraint(table, attribute, options = {})
        name = Util.constraint_name(table, attribute, 'inclusion', options)
        table = Util.wrap_identifier(table)
        execute("ALTER TABLE #{table} DROP CONSTRAINT #{name}")
      end
    end
  end
end
