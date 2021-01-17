require "base64"
require 'json'
require 'digest'

module JekyllSvelteSlabs

  class Tag < Liquid::Block

    VALID_SYNTAX = %r!
      ([\w-]+)\s*=\s*
      (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
    !x.freeze
    VARIABLE_SYNTAX = %r!
      (?<variable>[^{]*(\{\{\s*[\w\-.]+\s*(\|.*)?\}\}[^\s{}]*)+)
      (?<params>.*)
    !mx.freeze

    FULL_VALID_SYNTAX = %r!\A\s*(?:#{VALID_SYNTAX}(?=\s|\z)\s*)*\z!.freeze
    VALID_FILENAME_CHARS = %r!^[\w/.-]+$!.freeze
    INVALID_SEQUENCES = %r![./]{2,}!.freeze

    def initialize(tag_name, markup, tokens)
      super
      markup  = markup.strip
      matched = markup.match(VARIABLE_SYNTAX)
      if matched
        @file = matched["variable"].strip
        @params = matched["params"].strip
      else
        @file, @params = markup.split(%r!\s+!, 2)
      end
      validate_params if @params
      @tag_name = tag_name
    end

    def blank?
      false
    end

    # Iterate a hash (incl. arrays) to delete named keys
    def purge_keys_from_hash(params, keys)
      params.each do |k,v|
        value = v || k

        if value.is_a?(Hash) || value.is_a?(Array)
          purge_keys_from_hash(value, keys)
        else
          params.delete(k) if keys.include?(k)
        end
      end
    end

    # Remove a bind if specified, as well as any keys listed in the site config
    def clean_params(context, params)
      params.delete('bind')

      slab_config = context['site']['svelte_slabs']
      return unless slab_config

      purge_keys = slab_config['remove_keys']
      unless purge_keys.nil?
        purge_keys_from_hash(params, purge_keys)
      end
    end

    def parse_params(context)
      params = {}
      @params.scan(VALID_SYNTAX) do |key, d_quoted, s_quoted, variable|
        value = if d_quoted
                  d_quoted.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted
                elsif s_quoted
                  s_quoted.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted
                elsif variable
                  context[variable]
                end
                
        # Turn arrays of Documents into arrays of DocumentDrops
        # so that the to_json in render pulls the hash not the content
        if value.class == Array
          value = value.map {|v| v.class == Jekyll::Document ? v.to_liquid : v}
        end

        params[key] = value
      end

      params.each do |key, value|
        if key == 'bind'
          valueHash = {}.merge(value)
          params = valueHash.merge(params)
          next
        end
      end

      clean_params(context, params)

      params
    end

    def validate_file_name(file)
      if INVALID_SEQUENCES.match?(file) || !VALID_FILENAME_CHARS.match?(file)
        raise ArgumentError, <<~MSG
          Invalid syntax for svelte tag. File contains invalid characters or sequences:
            #{file}
          Valid syntax:
          {% #{@tag_name} component-name param='value' param2='value' %}
            <p>HTML Content</p>
          {% end#{@tag_name} %}
        MSG
      end
    end

    def validate_params
      unless FULL_VALID_SYNTAX.match?(@params)
        raise ArgumentError, <<~MSG
          Invalid syntax for svelte tag:
          #{@params}
          Valid syntax:
          {% #{@tag_name} component-name param='value' param2='value' %}
            <p>HTML Content</p>
          {% end#{@tag_name} %}
        MSG
      end
    end

    # Render the variable if required
    def render_variable(context)
      Liquid::Template.parse(@file).render(context) if VARIABLE_SYNTAX.match?(@file)
    end


    def render(context)
      text = super
      # puts Base64.encode64(context[@data].to_json)

      # site = context.registers[:site]
      # puts site

      file = render_variable(context) || @file
      validate_file_name(file)

      svelte_data = @params ? parse_params(context).to_json : "{}"
      endpoint = Digest::MD5.hexdigest(svelte_data)

      <<~MSG
        <script>
          window.svelteSlabs = window.svelteSlabs || {};
          window.svelteSlabs["#{endpoint}"] = #{svelte_data};
        </script>
        <div data-svelte-slab="#{file}" data-svelte-slab-props="window:#{endpoint}">
          #{text}
        </div>
      MSG
    end

  end

end

Liquid::Template.register_tag("svelte", JekyllSvelteSlabs::Tag)