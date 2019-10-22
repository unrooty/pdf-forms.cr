require "./pdf_forms"
require "./pdf_forms/field"

file_path : String = "/home/volkov/Music/LANCER APPLICATION.pdf"

hash : Hash(String, String) = {"a" => "1"}

p PdfForms::Fdf.new(hash).to_pdf_data
p PdfForms.new.get_field_names(file_path)
