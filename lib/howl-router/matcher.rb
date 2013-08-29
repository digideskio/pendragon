require 'mustermann'

class Howl
  class Matcher
    # @param [String] path The path is string or regexp.
    # @option options [Hash] :capture Set capture for path pattern.
    # @option options [Hash] :default_values Set default_values for path pattern.
    #
    # @return [Howl::Matcher]
    #
    def initialize(path, options = {})
      @path           = path.is_a?(String) && path.empty? ? "/" : path
      @capture        = options.delete(:capture)
      @default_values = options.delete(:default_values)
    end

    # Do the matching.
    #
    # @param [String] pattern The pattern is actual path (path_info etc).
    #
    # @return [MatchData] If the pattern matched this route, return a MatchData.
    # @return [Nil] If the pattern doesn't matched this route, return a nil.
    #
    def match(pattern)
      handler.match(pattern)
    end

    # Expand the path with params.
    #
    # @param [Hash] params The params for path pattern.
    #
    # @example
    #   matcher = Howl::Matcher.new("/foo/:bar")
    #   matcher.expand(:bar => 123) #=> "/foo/123"
    #   matcher.expand(:bar => "bar", :baz => "test") #=> "/foo/bar?baz=test"
    #
    # @return [String] A expaneded path.
    def expand(params)
      params = params.dup
      query = params.keys.inject({}) do |result, key|
        result[key] = params.delete(key) if !handler.names.include?(key.to_s)
        result
      end
      params.merge!(@default_values) if @default_values.is_a?(Hash)
      expanded_path = handler.expand(params)
      expanded_path = expanded_path + "?" + query.map{|k,v| "#{k}=#{v}" }.join("&") unless query.empty?
      expanded_path
    end

    # @return [Boolean] This matcher's handler is mustermann ?
    def mustermann?
      handler.class == Mustermann::Rails
    end

    # @return [Mustermann::Rails] Return a Mustermann::Rails when @path is string.
    # @return [Regexp] Return a regexp when @path is regexp.
    def handler
      @handler ||= case @path
      when String
        Mustermann.new(@path, :type => :rails, :capture => @capture, :uri_decode => nil)
      when Regexp
        /^(?:#{@path})$/
      end
    end

    # @return [String] Return a converted handler.
    def to_s
      handler.to_s
    end

    # @return [Array] Return a named captures.
    def names
      handler.names.map(&:to_sym)
    end
  end
end
