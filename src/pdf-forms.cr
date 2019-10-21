require "./pdf_forms"
require "./pdf_forms/field"

file_path : String = "/home/volkov/Music/pdf_templates/pdf_templates/15/LANCER_APP_09-03-2019.pdf"

output = Process.run(
  "/usr/bin/pdftk",
  ["/home/volkov/Music/pdf_templates/pdf_templates/15/LANCER_APP_09-03-2019.pdf", "dump_data_fields"], output: Process::Redirect::Pipe) do |process|
  process.output.gets_to_end
end

fields = [] of String

fields = output.split("---\n").map do |field_text|
  PdfForms::Field.new field_text if field_text =~ /FieldName:/
end

#p "hello".methods
