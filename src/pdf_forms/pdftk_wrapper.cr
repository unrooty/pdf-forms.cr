# coding: UTF-8

module PdfForms
  class PdftkError < Exception
  end

  # Wraps calls to PdfTk
  class PdftkWrapper
    include NormalizePath

    setter pdftk_path : String
    setter options : Hash(String, String | Bool)

    # Initializes a new wrapper instance. Pdftk will be autodetected from PATH:
    # PdftkWrapper.new(:flatten => true, :encrypt => true, :encrypt_options => "allow Printing")
    #
    # The pdftk binary may also be explecitly specified:
    # PdftkWrapper.new("/usr/bin/pdftk", :flatten => true, :encrypt => true, :encrypt_options => "allow Printing")
    #
    # Besides the options shown above, the drop_xfa or drop_xmp options are
    # also supported.
    def initialize(pdftk_path : String = PDFTK_PATH, options = {} of String => String | Bool)
      @pdftk_path = pdftk_path
      @options = options
    end

    # pdftk.fill_form "/path/to/form.pdf", "/path/to/destination.pdf", :field1 => "value 1"
    def fill_form(template : String, destination : String, data : Hash(String, String) = {} of String => String,
                  fill_options : Hash(String, String | Bool) = {} of String => String | Bool)
      q_template = expanded_path(template)
      q_destination = expanded_path(destination)
      fdf = data_format(data)
      tmp = File.tempfile("pdf_forms-fdf")
      tmp.close
      fdf.save_to tmp.path
      fill_options = {"tmp_path" => tmp.path}.merge(fill_options)

      args = [q_template, "fill_form", expanded_path(tmp.path), "output", q_destination]

      result = call_pdftk(append_options(args, fill_options))

      unless File.readable?(destination) && File.size(destination) > 0
        fdf_path = nil
        begin
          fdf_path = File.join(File.dirname(tmp.path), "#{Time.local.to_s "%Y%m%d%H%M%S"}.fdf")
          fdf.save_to fdf_path
        rescue e : Exception
          fdf_path = e.message
        end
        raise PdftkError.new("failed to fill form with command\n#{@pdftk_path} #{args.flatten.compact.join " "}\ncommand output was:\n#{result}\nfailing form data has been saved to #{fdf_path}")
      end
    ensure
      tmp.delete if tmp
    end

    # pdftk.read "/path/to/form.pdf"
    # returns an instance of PdfForms::Pdf representing the given template
    def read(path)
      Pdf.new path, @pdftk_path, @options
    end

    # Get field metadata for template
    #
    # Initialize the object with utf8_fields: true to get utf8 encoded field
    # metadata.
    def get_fields(template)
      read(template).fields
    end

    # get field names for template
    #
    # Initialize the object with utf8_fields: true to get utf8 encoded field
    # names.
    def get_field_names(template)
      read(template).fields.map { |f| f.name }
    end

    # returns the commands output, check general execution success with
    # $?.success?
    def call_pdftk(args : Array(String))
      Process.run(@pdftk_path, args, output: Process::Redirect::Pipe) do |process|
        process.output.gets_to_end
      end
    end

    # concatenate documents, can optionally specify page ranges
    #
    # args: in_file1, {in_file2 => ["1-2", "4-10"]}, ... , in_file_n, output
    def cat(*args)
      args = args.to_a
      in_files = [] of String
      page_ranges = [] of String
      file_handle = "A"

      output_index = args.to_a.size - 1

      output = expanded_path(args[output_index])

      args.to_a.delete_at(output_index)

      args.to_a.flatten.compact.each do |in_file|
        if in_file.is_a? Hash
          path = in_file.keys.first
          page_ranges += in_file.values.first.map { |range| "#{file_handle}#{range}" }
        else
          path = in_file
          page_ranges.push "#{file_handle}"
        end
        in_files.push "#{file_handle}=#{expanded_path(path)}"
        file_handle = String.new(Slice[file_handle.bytes[0] + 1])
      end

      call_pdftk([in_files, "cat", page_ranges, "output", output].flatten)
    end

    # stamp one pdf with another
    #
    # args: primary_file, stamp_file, output
    def stamp(primary_file, stamp_file, output)
      call_pdftk([primary_file, "stamp", stamp_file, "output", output])
    end

    # applies each page of the stamp PDF to the corresponding page of the input PDF
    # args: primary_file, stamp_file, output
    def multistamp(primary_file, stamp_file, output)
      call_pdftk([primary_file, "multistamp", stamp_file, "output", output])
    end

    private def data_format(data)
      case @options["data_format"]?
      when "xfdf"
        PdfForms::XFdf.new(data)
      else
        PdfForms::Fdf.new(data)
      end
    end

    private def option_or_global(attrib : String, local = {} of String => String)
      local[attrib]? || @options[attrib]?
    end

    ALLOWED_OPTIONS = %w[drop_xmp drop_xfa flatten need_appearances]

    private def append_options(args : Array(String), local_options = {} of String => String) : Array(String)
      return args if @options.empty? && local_options.empty?

      args = args.dup

      ALLOWED_OPTIONS.each do |option|
        if option_or_global(option, local_options)
          args << option.to_s
        end
      end
      if option_or_global("encrypt", local_options)
        encrypt_pass = option_or_global("encrypt_password", local_options)
        encrypt_pass ||= Random::Secure.urlsafe_base64
        encrypt_options = option_or_global("encrypt_options", local_options)
        encrypt_options = encrypt_options.split if encrypt_options.is_a?(String)

        if encrypt_options.is_a?(Array(String))
          args += ["encrypt_128bit", "owner_pw", encrypt_pass.to_s] + encrypt_options
        else
          args += ["encrypt_128bit", "owner_pw", encrypt_pass.to_s, encrypt_options.to_s]
        end
      end

      args.flatten.compact.reject(&.blank?)
    end

    private def normalize_args(*args)
      arguments : Tuple(String) = args.dup
      options = {} of String => String
      if first_arg = arguments[0]
        case first_arg
        when String
          pdftk = first_arg
          options = args.shift || {} of String => String
          raise ArgumentError.new("expected hash, got #{options.class.name}") unless Hash === options
        when Hash
          options = first_arg
        else
          raise ArgumentError.new("expected string or hash, got #{first_arg.class.name}")
        end
      end
      [@pdftk_path, options]
    end

    private def file_exists?(path)
      File.exists?(path)
    end
  end
end
