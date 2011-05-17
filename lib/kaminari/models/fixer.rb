module Kaminari

  class Fixer

    protected

    def self.do_array(collection, options)
      Kaminari.paginate_array(collection)
      collection.instance_eval <<-EVAL
        def current_page
          @current_page || 1
        end
        def limit_value
          per_page
        end
        def per_page
          @per_page || size
        end
        def page(value)
          @current_page = value.to_i.zero? ? 1 : value.to_i
          self
        end
        def per(value)
          @per_page = value
          self
        end
        def total_count
          #{options[:total].to_s + ' ||' if options[:total]} size
        end
        def num_pages
          (total_count.to_f / (per_page.zero? ? 1 : per_page)).ceil
        end
        def offset
          (current_page - 1) * per_page
        end
        def offset_value
          offset
        end
        def scoped
          self[offset...offset + per_page]
        end
        def all
          scoped
        end
      EVAL
      collection
    end

    def self.do_thinking_sphinx(collection, options)
      collection.instance_eval <<-EVAL
        def limit_value
          per_page
        end
        def offset_value
          offset
        end
        def page(value)
          self
        end
        def per(value)
          self
        end
        def total_count
          total_entries
        end
        def scoped
          self
        end
        def num_pages
          total_pages
        end
        def all
          scoped
        end
      EVAL
      collection
    end

    def self.do_ar_relation(collection, options)
      collection.instance_eval <<-EVAL
        def total_count
          #{options[:total]}
        end
      EVAL
      collection
    end

    public

    def self.do(input_collection, options = {})
      collection = input_collection
      collection = if collection.is_a?(ThinkingSphinx::Search)
        do_thinking_sphinx(collection, options)
      elsif collection.is_a?(ActiveRecord::Relation) && options[:total]
        do_ar_relation(collection, options)
      elsif collection.is_a?(Array)
        do_array(collection, options)
      end
      collection
    end
  end
end
