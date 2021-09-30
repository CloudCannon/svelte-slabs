# frozen_string_literal: true

require "json/ext"
require_relative "./page-without-a-file"

module JekyllSvelteSlabs
  class SiteData
    def self.output(site, data, filename)
      @site = site

      generate_file(filename, data)
    end

    def self.generate_file(filename, content)
      dest = destination_json_path(filename)
      FileUtils.mkdir_p(File.dirname(dest))
      File.open(dest, "w") { |file| file.write(content) }
      @site.keep_files ||= []
      @site.keep_files << json_path(filename)
    end

    def self.destination_json_path(filename)
      Jekyll.sanitized_path(@site.dest, json_path(filename))
    end

    def self.json_path(filename)
      "_slabs/#{filename}.json"
    end
  end
end
