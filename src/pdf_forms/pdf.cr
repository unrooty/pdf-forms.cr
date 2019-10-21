# coding: UTF-8

require "./field"

module PdfForms
  class Pdf
    include NormalizePath

    @path : String
    @pdftk : PdftkWrapper
    @fields : Array(Field) = [] of Field

    getter :path, :options

    def initialize(path, pdftk, options = {} of Symbol => String)
      @options = options
      @path = path
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
      fields.detect { |f| f.name == name }
    end

    private def read_fields
      dump_method = options[:utf8_fields] ? "dump_data_fields_utf8" : "dump_data_fields"
      field_output = @pdftk.call_pdftk path, dump_method
      @fields = field_output.split(/^---\n/).map do |field_text|
        Field.new field_text if field_text =~ /FieldName:/
      end.compact
    end
  end
end
