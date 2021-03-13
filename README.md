# pdf-forms.cr

Fill out PDF forms with [pdftk](https://gitlab.com/pdftk-java/pdftk).

This shard is a port of the [pdf-forms](https://github.com/jkraemer/pdf-forms) Ruby gem.

## Important Information

This shard has been tested and works great with PDFtk 3.0, Ubuntu 18.04, Ubuntu 20.04 and Crystal 0.31.1 - 0.36.1.

Also it tested against MacOS latest and Crystal 0.36.1

The installation of the PDFtk 3.0 is recommended for normal work.

Shard can work with PDFtk 2.0 if PDFtk has access to the **/tmp** diretcory. 

## Installation

-  Install PDFtk (Ubuntu 18.04 only)

```bash
  wget http://launchpadlibrarian.net/475142792/pdftk-java_3.0.9-1_all.deb
  sudo apt install default-jre-headless libcommons-lang3-java libbcprov-java
  sudo dpkg -i pdftk-java_3.0.9-1_all.deb
```

- Install PDFtk (Ubuntu 20.04 only)

```bash
  sudo apt install pdftk
```

- Install PDFtk (MacOS latest only)
```bash
  brew install pdftk-java
```

- Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pdf-forms.cr:
       github: unrooty/pdf-forms.cr
       version: 0.2.0 # optional
   ```

-  Run 
  ```bash 
    shards install
  ```

## Usage

### FDF/XFdf creation

```ruby
require 'pdf_forms'

fdf = PdfForms::Fdf.new("key" => "value", "other_key" => "other value")

# use to_pdf_data if you just want the fdf data, without writing it to a file
puts fdf.to_pdf_data

# write fdf file
fdf.save_to "path/to/file.fdf"
```

To generate XFDF instead of FDF instantiate `PdfForms::XFdf` instead of `PdfForms::Fdf`.

### Query form fields and fill out PDF forms with pdftk

```ruby
require 'pdf_forms'

# adjust the pdftk path to suit your pdftk installation
# add "data_format" => "xfdf" option to generate XFDF instead of FDF when
# filling a form (XFDF is supposed to have better support for non-western encodings)
# add "data_format" => "FdfHex" option to generate FDF with values passed in UTF16 hexadecimal format (Hexadecimal format has also proven more reliable for passing latin accented characters to pdftk)
# add :utf8_fields => true in order to get UTF8 encoded field metadata (this will use dump_data_fields_utf8 instead of dump_data_fields in the call to pdftk)
pdftk = PdfForms.new("/usr/local/bin/pdftk")

# find out the field names that are present in form.pdf
pdftk.get_field_names("path/to/form.pdf")

# take form.pdf, set the "foo" field to "bar" and save the document to myform.pdf
pdftk.fill_form("/path/to/form.pdf", "myform.pdf", { "foo" => "bar" })

# optionally, add the "flatten" option to prevent editing of a filled out form.
# Other supported options are "drop_xfa" and "drop_xmp".
pdftk.fill_form("/path/to/form.pdf", "myform.pdf", { "foo" => "bar"}, { "flatten" => true })

# to enable PDF encryption, pass encrypt: true. By default, a random 'owner
# password' will be used, but you can also set one with the :encrypt_pw option.
pdftk.fill_form("/path/to/form.pdf", "myform.pdf", { "foo" => "bar" }, { "encrypt" => true, "encrypt_options" => "allow printing" })

# you can also protect the PDF even from opening by specifying an additional user_pw option:
pdftk.fill_form("/path/to/form.pdf", "myform.pdf", { "foo" => "bar" }, { "encrypt" => true, "encrypt_options" => "user_pw secret" })
```

Any options shown above can also be set when initializing the PdfForms
instance. In this case, options given to `fill_form` will override the global
options.

### Non-ASCII Characters (UTF8 etc) are not displayed in the filled out PDF

First, check if the field value has been stored properly in the output PDF using `pdftk output.pdf dump_data_fields_utf8`.

If it has been stored but did not render, your input PDF lacks the proper font for your kind of characters. Re-create it and embed any necessary fonts.
If value has not been stored, most of the time there is a problem with filling out the form on your side, not with this shard.

## Testing

Currencly shard uses [minitest.cr](https://github.com/ysbaddaden/minitest.cr).

To run specs use `crystal run ./spec/*_test.cr` command.

## Contributing

1. Fork it (<https://github.com/unrooty/pdf-forms.cr/fork>).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.

## Contributors

- [Vladislav Volkov](https://github.com/unrooty) - creator and maintainer
