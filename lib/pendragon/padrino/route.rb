require 'pendragon/route'

module Pendragon
  module Padrino
    class Route < ::Pendragon::Route
      attr_accessor :action, :cache, :cache_key, :cache_expires, :parent,
                    :use_layout, :controller, :user_agent, :path_for_generation

      def before_filters(&block)
        @_before_filters ||= []
        @_before_filters << block if block_given?
        @_before_filters
      end

      def after_filters(&block)
        @_after_filters ||= []
        @_after_filters << block if block_given?
        @_after_filters
      end

      def custom_conditions(&block)
        @_custom_conditions ||= []
        @_custom_conditions << block if block_given?
        @_custom_conditions
      end

      def call(app, *args)
        @block.call(app, *args)
      end

      def request_methods
        [verb.to_s.upcase]
      end

      def original_path
        @path
      end

      def significant_variable_names
        @significant_variable_names ||= if @path.is_a?(String)
          @path.scan(/(^|[^\\])[:\*]([a-zA-Z0-9_]+)/).map{|p| p.last.to_sym}
        elsif @path.is_a?(Regexp) and @path.respond_to?(:named_captures)
          @path.named_captures.keys.map(&:to_sym)
        else
          []
        end
      end
    end
  end
end
