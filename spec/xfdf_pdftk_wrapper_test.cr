require "./test_helper"
require "./pdftk_wrapper_test"

class XfdfPdftkWrapperTest < PdftkWrapperTest
  def data_format
    "xfdf"
  end

  def test_fill_form_with_japanese
    japanese_string = "スペイン"
    @pdftk.fill_form(
      "./spec/fixtures/japanese.pdf",
      "./output.pdf",
      { "nationality" => japanese_string }
    )

    assert File.size("./output.pdf") > 0

    assert field = @pdftk.get_fields("./output.pdf").find{|f| f.name == "nationality"}
    assert value = field.try(&.value)
    refute value.nil?
    assert_equal japanese_string, value

    assert field = @pdftk_utf8.get_fields("./output.pdf").find{|f| f.name == "nationality"}
    assert value = field.try(&.value)
    refute value.nil?
    assert_equal japanese_string, value

    File.delete("./output.pdf")
  end
end
