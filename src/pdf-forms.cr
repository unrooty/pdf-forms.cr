require "./pdf_forms"
require "./pdf_forms/field"

file_path : String = "/home/volkov/Music/LANCER APPLICATION.pdf"

PdfForms.new.fill_form(file_path, "/home/volkov/Music/1.pdf", { "Y" => "Hello" })
