# coding: UTF-8

# require "pathname"

module PdfForms
  module NormalizePath
    def normalized_path(path) : String
      Path[path].normalize.to_s
    end

    def expanded_path(path) : String
      Path[path].expand.to_s
    end
  end
end
