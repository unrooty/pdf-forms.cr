# coding: utf-8

require "./test_helper"
class PdftkWrapperTest < Minitest::Test

  @pdftk : PdfForms::PdftkWrapper = PdfForms::PdftkWrapper.new
  @pdftk_utf8 : PdfForms::PdftkWrapper = PdfForms::PdftkWrapper.new
  @pdftk_options : PdfForms::PdftkWrapper = PdfForms::PdftkWrapper.new
  @pdftk_with_encrypt_options : PdfForms::PdftkWrapper = PdfForms::PdftkWrapper.new

  def setup
    @pdftk = PdfForms.new(PdfForms::PDFTK_PATH,
      { "data_format" => data_format } of String => String | Bool
    )

    @pdftk_utf8 = PdfForms.new(PdfForms::PDFTK_PATH, {
      "utf8_fields" => true,
      "data_format" => data_format
    })

    @pdftk_options = PdfForms.new({
      "flatten" => true,
      "encrypt" => true,
      "data_format" => data_format
    })

    @pdftk_with_encrypt_options = PdfForms.new(PdfForms::PDFTK_PATH, {
      "flatten" => true,
      "encrypt" => true,
      "data_format" => data_format,
      "encrypt_password" => "secret",
      "encrypt_options" => "allow printing"
    })
  end

  # def test_should_check_executable
  #   assert_raises(Cliver::Dependency::NotFound){ PdfForms.new("foobar") }
  # end

  def test_get_fields_utf8
    assert fields = @pdftk_utf8.get_fields( "./spec/fixtures/utf8.pdf" )
    assert fields.any?
    assert fields.find{|f| f.name == "•?((¯°·._.• µţƒ-8 ƒɨ€ℓď •._.·°¯))؟•"}
  end

  def test_get_field_names_utf8
    assert fields = @pdftk_utf8.get_field_names( "./spec/fixtures/utf8.pdf" )
    assert fields.any?
    assert fields.includes?("•?((¯°·._.• µţƒ-8 ƒɨ€ℓď •._.·°¯))؟•")
  end

  def test_get_fields
    assert fields = @pdftk.get_fields( "./spec/fixtures/form.pdf" )
    assert fields.any?
    assert fields.find{|f| f.name == "program_name"}
  end

  def test_get_field_names
    assert fields = @pdftk.get_field_names( "./spec/fixtures/form.pdf" )
    assert fields.any?
    assert fields.includes?("program_name")
  end

  def test_fill_form
    @pdftk.fill_form("./spec/fixtures/form.pdf",
                     "output.pdf",
                     { "program_name" => "SOME TEXT" })

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_fill_form_spaced_filename
    @pdftk.fill_form("./spec/fixtures/form.pdf",
                     "out put.pdf",
                     { "program_name" => "SOME TEXT" })

    assert File.size("out put.pdf") > 0
    File.delete("./out put.pdf")
  end

  def test_fill_form_and_flatten
    @pdftk.fill_form("./spec/fixtures/form.pdf",
                     "output.pdf",
                     {"program_name" => "SOME TEXT"},
                     {"flatten" => true})

    assert File.size("output.pdf") > 0
    fields = @pdftk.get_fields("output.pdf")
    assert fields.size == 0
    File.delete("./output.pdf")
  end

  def test_fill_form_encrypted_and_flattened
    @pdftk_options.fill_form("./spec/fixtures/form.pdf",
                             "output.pdf",
                             {"program_name" => "SOME TEXT"})

    assert File.size("output.pdf") > 0
    assert @pdftk.get_fields("output.pdf").size == 0
    File.delete("./output.pdf")
  end

  def test_fill_form_and_encrypt_for_opening
    pdftk = PdfForms.new(PdfForms::PDFTK_PATH, {
      "encrypt" => true,
      "encrypt_password" => "secret",
      "encrypt_options" => "allow printing user_pw baz"
    })

    pdftk.fill_form("./spec/fixtures/form.pdf",
                    "output.pdf",
                    { "program_name" => "SOME TEXT" })

    assert File.size("output.pdf") > 0
    output = `pdftk output.pdf dump_data_fields 2>&1`
    assert_match /OWNER (OR USER )?PASSWORD REQUIRED/, output
    File.delete("./output.pdf")
  end

  def test_fill_form_with_non_ascii_iso_8859_chars
    @pdftk_options.fill_form("./spec/fixtures/form.pdf",
                             "output_umlauts.pdf",
                             { "program_name" => "with ß and ümlaut" })

    assert File.size("output_umlauts.pdf") > 0
    File.delete("./output_umlauts.pdf")
  end

  def test_cat_documents
    @pdftk.cat("./spec/fixtures/one.pdf", "./spec/fixtures/two.pdf", "output.pdf")

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_cat_documents_remove_page
    @pdftk.cat({"./spec/fixtures/form.pdf" => ["1-2", "4-5"]}, "output.pdf")

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_cat_documents_page_ranges
    @pdftk.cat({"./spec/fixtures/form.pdf" => ["1-2", "4-5"]},
               "./spec/fixtures/one.pdf",
               {"./spec/fixtures/two.pdf" => ["1"]},
               "output.pdf")

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_stamp_document
    @pdftk.stamp("./spec/fixtures/one.pdf", "./spec/fixtures/stamp.pdf", "output.pdf")

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_multistamp_document
    @pdftk.multistamp("./spec/fixtures/one.pdf", "./spec/fixtures/stamp.pdf", "output.pdf")

    assert File.size("output.pdf") > 0
    File.delete("./output.pdf")
  end

  def test_fill_form_cli_injection
    @pdftk.fill_form("./spec/fixtures/form.pdf",
                     "output.pdf",
                     touch("./spec/cli_injection"),
                     { "program_name" => "SOME TEXT" }) rescue nil

    refute File.exist?("test/cli_injection"), "CLI injection successful"
  ensure
    File.delete("./output.pdf") if File.exists?("./output.pdf")
    File.delete("./spec/cli_injection") if File.exists("./spec/cli_injection")
  end

  def data_format
    "fdf"
  end
end
