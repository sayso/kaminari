module Kaminari
  module ActiveRecordRelationMethods
    extend ActiveSupport::Concern
    module InstanceMethods
      def total_count #:nodoc:
        c = except(:offset, :limit).count(nil, {:dont_use_kaminari => true})
        # .group returns an OrderdHash that responds to #count
        c.respond_to?(:count) ? c.count : c
      end

      def size
        [[0,(total_count - (current_page - 1) * limit_value)].max, limit_value].min
      end

      def count(column_name = nil, options = {})
        dont_use_kaminari = options.delete(:dont_use_kaminari)
        dont_use_kaminari ? super : size
      end
    end
  end
end
