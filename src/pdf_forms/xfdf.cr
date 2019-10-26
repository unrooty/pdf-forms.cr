# coding: UTF-8

require "xml"

module PdfForms
  # Map keys and values to Adobe"s XFDF format.
  class XFdf < DataFormat
    def initialize(data = {} of String => String, options = {} of String => String)
      super
    end

    private def encode_data(pdf_data)
      pdf_data
    end

    private def quote(value)
      case
      when value.is_a?(String)
        value.to_s
      when value.is_a?(Array)
        value.map { |v| quote(v) }.join(" ").to_s
      when value.nil?
        value.to_s
      else
        raise "Invalid value passed! Must be an Array(String) | String | Nil."
      end
    end

    private def header
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">
          <fields>
      "
    end

    private def field(key, value)
      "<field name=\"#{key}\"><value>#{quote(value)}</value></field>"
    end

    private def footer
      "</fields></xfdf>"
    end
  end
end
