# coding: UTF-8

# require "pathname"

module PdfForms
  module NormalizePath
    def normalize_path(path)
      Path[path].normalize
    end
  end
end
