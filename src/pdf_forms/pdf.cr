# coding: UTF-8

require "./field"

module PdfForms
  class Pdf
    include NormalizePath

    setter path : String
    setter pdftk : String
    setter options : Hash(String, String | Bool)

    getter fields : Array(Field) | Nil = nil

    def initialize(path : String, pdftk : String = PDFTK_PATH, options = {} of String => String | Bool)
      @options = options
      @path = expanded_path(path)
      raise "File not readable!" unless File.readable?(@path)
      @pdftk = pdftk
    end

    # list of field objects for all defined fields
    #
    # Initialize the object with utf8_fields: true to get utf8 encoded field
    # names.
    def fields
      @fields ||= read_fields
    end

    # the field object for the named field
    def field(name)
      fields.find { |f| f.name == name }
    end

    private def read_fields
      dump_method = @options["utf8_fields"]? ? "dump_data_fields_utf8" : "dump_data_fields"

      @fields = fields_output(dump_method).split("---\n").map do |field_text|
        Field.new field_text if field_text =~ /FieldName:/
      end.compact
    end

    private def fields_output(dump_method)
      Process.run(@pdftk, [@path, dump_method], output: Process::Redirect::Pipe) do |process|
        process.output.gets_to_end
      end
    rescue exception
      raise "PDF fields dump failed due to #{exception.message}"
    end
  end
end
