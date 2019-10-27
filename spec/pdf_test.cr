# coding: UTF-8

require "./test_helper"

class PdfTest < Minitest::Test
  def setup
  end

  def test_fields
    pdf = PdfForms::Pdf.new "./spec/fixtures/form.pdf", PdfForms::PDFTK_PATH
    assert fields = pdf.fields
    assert fields.any?
    assert fields.find { |f| f.name == "program_name" }
  end

  def test_fields_utf8
    pdf = PdfForms::Pdf.new "./spec/fixtures/utf8.pdf",
      PdfForms::PDFTK_PATH,
      {"utf8_fields" => true} of String => String | Bool

    assert fields = pdf.fields
    assert fields.any?
    assert fields.find { |f| f.name == "•?((¯°·._.• µţƒ-8 ƒɨ€ℓď •._.·°¯))؟•" }
  end

  def test_should_have_field_metadata
    pdf = PdfForms::Pdf.new "./spec/fixtures/form.pdf", PdfForms::PDFTK_PATH
    assert f = pdf.field("area5_answer4")
    assert_equal "Button", f.try(&.type)
    assert_equal ["NOT YET", "Off", "SOMETIMES", "YES"].sort, f.try(&.options).try(&.sort)
  end

  def test_should_error_when_file_not_readable
    assert_raises(Exception) {
      PdfForms::Pdf.new "foo/bar.pdf", PdfForms::PDFTK_PATH
    }
  end
end
