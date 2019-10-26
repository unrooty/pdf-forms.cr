# coding: UTF-8

module PdfForms
  # Map keys and values to Adobe"s FDF format.
  #
  # Straight port of Perl"s PDF::FDF::Simple by Steffen Schwigon.
  # Parsing FDF files is not supported (yet).
  class Fdf < DataFormat
    def initialize(data, options = {} of String => String)
      super
    end

    private def encode_data(fdf)
      # I have yet to see a version of pdftk which can handle UTF8 input,
      # so we convert to ISO-8859-15 here, replacing unknown / invalid chars
      # with the default replacement which is "?".

      encoded_string = String.new(fdf.encode("ISO-8859-15", invalid: :skip)).scrub

      return encoded_string if encoded_string.valid_encoding?

      encoded_string.scrub
    end

    # pp 559 https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/pdf_reference_archives/PDFReference.pdf
    private def header
      header = "%FDF-1.2\n\n1 0 obj\n<<\n/FDF << /Fields 2 0 R"

      # /F
      header += "/F (#{@file})" if @file
      # /UF
      header += "/UF (#{@ufile})" if @ufile
      # /ID
      header += "/ID[" + @id.compact.try(&.join) + "]" unless @id.empty?

      header += ">>\n>>\nendobj\n2 0 obj\n["
      header
    end

    # pp 561 https://www.adobe.com/content/dam/acom/en/devnet/pdf/pdfs/pdf_reference_archives/PDFReference.pdf
    private def field(key, value)
      field = "<<"
      field += "/T" + "(#{key})"
      field += "/V" + (value.is_a?(Array) ? "[#{value.map { |v| "(#{quote(v)})" }.join}]" : "(#{quote(value)})")
      field += ">>\n"
      field
    end

    private def quote(value)
      value.to_s.gsub(/\n/, "\r")
    end

    FOOTER =
      "]\n" \
      "endobj\n" \
      "trailer\n" \
      "<<\n" \
      "/Root 1 0 R\n" \
      "\n" \
      ">>\n" \
      "%%EOF\n"

    private def footer
      FOOTER
    end
  end
end
