# coding UTF-8

module PdfForms
  class DataFormat
    setter data : Hash(String, String) | Hash(String, Array(String)) | Hash(String, Nil)
    setter options : Hash(String, String)
    setter file : String | Nil
    setter ufile : String | Nil
    setter id : Array(String)

    def initialize(data = {} of String => String, options = {} of String => String)
      @data = data
      @file = nil
      @ufile = nil
      @id = [] of String
      @options = options
    end

    # generate PDF content in this data format
    def to_pdf_data
      pdf_data = header

      @data.each do |key, value|
        if value.is_a?(Hash(String, String))
          value.each do |sub_key, sub_value|
            pdf_data << field("#{key}_#{sub_key}", sub_value)
          end
        else
          pdf_data += field(key, value)
        end
      end

      pdf_data += footer
      return encode_data(pdf_data)
    end

    def to_fdf
      to_pdf_data
    end

    # write fdf content to path
    def save_to(path)
      (File.open(path, "wb") << to_fdf).close
    end

    private def encode_data(data)
      data
    end

    private def header
      raise "Not Implemented"
    end

    private def field(key, value)
      raise "Not Implemented"
    end

    private def footer
      raise "Not Implemented"
    end
  end
end
