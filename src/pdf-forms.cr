require "./pdf_forms"
require "benchmark"

# system_file_path : String = "/home/volkov/Music/'LANCER APPLICATION.pdf'"
# crystal_file_path : String = "/home/volkov/Music/LANCER APPLICATION.pdf"

# done = Channel(Int32).new(250)

# channel = Channel(Nil).new(500)

# index = 0

# 4.times do
#   spawn do
#     while index < 10
#       channel.send(PdfForms.new.fill_form(file_path, "/home/volkov/Music/first_fiber/#{index}.pdf", {"FID-4FB3" => "sldkfhsldkjfhskdlj"}))
#       index += 1
#     end
#   end
# end

# /tmp/20191023133953.fdf

# Benchmark.bm do |x|
#   x.report("System Call:") do
#     # 25.times do |index|
#     system "/home/volkov/Music/cpdftk cat #{system_file_path}"
#     # system "pdftk #{system_file_path} fill_form /tmp/20191023133953.fdf output /home/volkov/Music/first_fiber/1.pdf"
#     # PdfForms.new.fill_form(crystal_file_path, "/home/volkov/Music/first_fiber/#{index}.pdf", {"FID-4FB3" => "sldkfhsldkjfhskdlj"})
#     # end
#   end
# end

# p PdfForms.new.fill_form(
#   "/home/volkov/projects/shards/pdf-forms/spec/fixtures/form.pdf", ""
#   )

x = "B".ord

p x

if x.is_a?(UInt8)
  p String.new(Slice[x])
end


