require "./pdf_forms/version"
require "./pdf_forms/normalize_path"
require "./pdf_forms/data_format"
require "./pdf_forms/fdf"
require "./pdf_forms/xfdf"
require "./pdf_forms/fdf_hex"
require "./pdf_forms/pdf"
require "./pdf_forms/pdftk_wrapper"
require "./pdf_forms/constants"

module PdfForms
  def self.new(pdftk_path : String = PDFTK_PATH, options = {} of String => String | Bool)
    PdftkWrapper.new(pdftk_path, options)
  end

  def self.new(options = {} of String => String | Bool)
    PdftkWrapper.new(PDFTK_PATH, options)
  end
end
