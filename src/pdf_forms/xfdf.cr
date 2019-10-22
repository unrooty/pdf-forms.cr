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
      XML.parse(value.to_s).to_s
    end

    private def header
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">
          <fields>
      "
    end

    private def field(key, value)
      "<field name=\"#{key}\"><value>#{Array{value}.map{ |v| quote(v) }.join(" ")}</value></field>"
    end

    private def footer
      "</fields></xfdf>"
    end
  end
end
