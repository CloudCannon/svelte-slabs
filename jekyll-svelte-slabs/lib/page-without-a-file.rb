# frozen_string_literal: true

module JekyllSvelteSlabs
  # Utility class to help generate files with no source file
  class PageWithoutAFile < Jekyll::Page
    def read_yaml(*)
      @data ||= {}
    end
  end
end
