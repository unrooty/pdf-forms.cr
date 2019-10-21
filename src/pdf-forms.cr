require "./pdf_forms"
require "./pdf_forms/field"

file_path : String = "/home/volkov/Music/LANCER APPLICATION.pdf"

output = Process.run(
  "pdftk",
  [file_path, "dump_data_fields"], output: Process::Redirect::Pipe) do |process|
  process.output.gets_to_end
end

fields = [] of String

fields = output.split("---\n").map do |field_text|
  PdfForms::Field.new field_text if field_text =~ /FieldName:/
end

p fields.compact
