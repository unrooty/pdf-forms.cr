# coding: UTF-8

# require "pathname"

module PdfForms
  module NormalizePath
    def normalized_path(path) : String
      normalize_path(path).to_s
    end

    def normalize_path(path) : Path
      Path[path].normalize
    end
  end
end
