# coding: UTF-8

module PdfForms
  # Map keys and values to Adobe"s FDF format.
  #
  # This is a variation of the original Fdf data format, values are encoded in UTF16 hexadesimal
  # notation to improve compatibility with non ascii charsets.
  #
  # Information about hexadesimal FDF values was found here:
  #
  # http://stackoverflow.com/questions/6047970/weird-characters-when-filling-pdf-with-pdftk
  #
  class FdfHex < Fdf
    private def field(key, value)
      "<</T(#{key})/V" +
        (value.is_a?(Array) ? encode_many(value) : encode_value_as_hex(value)) +
        ">>\n"
    end

    private def encode_many(values : Array(String))
      "[#{values.map { |v| encode_value_as_hex(v) }.join}]"
    end

    private def encode_value_as_hex(value)
      byte_array = value.to_s.bytes.reject { |byte| byte == 0 }

      hex_array = byte_array.map { |byte| byte.to_s(16) }

      hex = hex_array.map { |hex| "0" * (4 - hex.size) + hex }.join

      "<FEFF" + hex.upcase + ">"
    end

    # Fdf implementation encodes to ISO-8859-15 which we do not want here.
    private def encode_data(fdf)
      fdf
    end
  end
end
