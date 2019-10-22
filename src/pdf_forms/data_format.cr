# coding UTF-8

module PdfForms
  class DataFormat
    setter data : Hash(String, String)
    setter options : Hash(String, String | Nil)
    setter file : String | Nil
    setter ufile : String | Nil
    setter id : Array | Nil

    def initialize(data : Hash(String, String) = {} of String => String, options : Hash(String, String) = {} of String => String)
      @data = data
      @file = nil
      @ufile = nil
      @id = nil
      @options = options
    end

    # generate PDF content in this data format
    def to_pdf_data
      pdf_data = header

      @data.each do |key, value|
        if Hash === value
          value.each do |sub_key, sub_value|
            pdf_data << field("#{key}_#{sub_key}", sub_value)
          end
        else
          pdf_data << field(key, value)
        end
      end

      pdf_data << footer
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
  end
end
