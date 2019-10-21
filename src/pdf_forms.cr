require "./pdf_forms/version"
require "./pdf_forms/normalize_path"
require "./pdf_forms/data_format"
# require "./pdf_forms/fdf"
# require "./pdf_forms/xfdf"
# require "./pdf_forms/fdf_hex"
require "./pdf_forms/pdf"
require "./pdf_forms/pdftk_wrapper"

module PdfForms
  def self.new(pdftk_url : String = "/usr/bin/pdftk", options = {} of Symbol => String)
    PdftkWrapper.new pdftk_url, options
  end
end
