# coding: UTF-8

require "./test_helper"

class FieldTest < Minitest::Test
  def setup
  end

  CHOICE_FIELD =
    "FieldType: Choice\n" \
    "FieldName: SomeChoiceField\n" \
    "FieldFlags: 71696384\n" \
    "FieldValue: http://github.com foo\n" \
    "FieldValueDefault:\n" \
    "FieldJustification: Left\n" \
    "FieldStateOption:\n" \
    "FieldStateOption: 010 Foo Bar\n" \
    "FieldStateOption: Another option (xyz)\n"

  def test_init_with_choice
    f = PdfForms::Field.new CHOICE_FIELD
    assert_equal "Choice", f.type
    assert_equal "SomeChoiceField", f.name
    assert_equal ["", "010 Foo Bar", "Another option (xyz)"], f.options

    assert_equal "http://github.com foo", f.value
    assert_equal "", f.value_default
    assert_equal "Left", f.justification
    assert_equal "71696384", f.flags
  end

  def test_to_hash
    f = PdfForms::Field.new CHOICE_FIELD
    assert f.responds_to?(:to_hash)
    assert_equal ["", "010 Foo Bar", "Another option (xyz)"], f.to_hash["options"]
  end

  UNKNOWN_FIELD =
    "FieldType: Choice\n" \
    "FieldFoo: FooTown\n" \
    "FieldBar: BarTown\n"

  def test_generate_new_field_key_accessors_on_the_fly
    f = PdfForms::Field.new UNKNOWN_FIELD
    assert_equal "FooTown", f.additional_attributes["foo"]
    assert_equal "BarTown", f.additional_attributes["bar"]
  end

  VALUE_WITH_COLON =
    "FieldType: Text\n" \
    "FieldName: Date\n" \
    "FieldNameAlt: Date: most recent\n"

  def test_field_values_with_colons
    f = PdfForms::Field.new VALUE_WITH_COLON
    assert_equal "Date: most recent", f.name_alt
  end

  MULTILINE_TEXT_VALUE =
    "1. First element of my list;\n" \
    "2. Second element of my list;\n" \
    "3. Third element of my list.\n" \
    "\n" \
    "This is my list.\n"

  MULTILINE_TEXT_FIELD =
    "FieldName: minhalista\n" \
    "FieldFlags: 4096\n" \
    "FieldValue: #{MULTILINE_TEXT_VALUE}\n" \
    "FieldJustification: Left\n"

  def test_text_field_with_multiple_lines
    f = PdfForms::Field.new MULTILINE_TEXT_FIELD
    assert_equal MULTILINE_TEXT_VALUE, f.value
  end
end
