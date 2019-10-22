require "./pdf_forms"
require "./pdf_forms/field"

file_path : String = "/home/volkov/Music/LANCER APPLICATION.pdf"

p PdfForms.new.get_field_names(file_path)
