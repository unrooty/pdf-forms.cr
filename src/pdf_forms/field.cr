# coding: UTF-8

module PdfForms
  class Field
    # FieldType: Button
    # FieldName: Sprachoptionen_Inverssuche_Widerspruch
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Ja
    # FieldStateOption: Off
    #
    # Representation of a PDF Form Field

    @name : String
    @type : String
    @options : String
    @flags : String
    @justification : String
    @value : String
    @value_default : String
    @name_alt : String
    @max_length : String
    @additional_attributes : String

    def initialize(field_description)
      build_attributes_hash(field_description)
    end

    private def build_attributes_hash(field_description)
      last_value = ""
      
      field_description.each_line do |line|
        if line.chomp =~ /^Field([A-Za-z]+):\s+(.*)/
          _, key, value = $~

          if key == 'StateOption'
            (@options ||= []) << value
          else
            last_value = value.chomp
            key = key.split(/(?=[A-Z])/).map(&:downcase).join('_')
            instance_variable_set("@#{key}", last_value)

            # dynamically add in fields that we didn't anticipate in ATTRS
            unless self.respond_to?(key.to_sym)
              proc = Proc.new { instance_variable_get("@#{key}".to_sym) }
              self.class.send(:define_method, key.to_sym, proc)
            end
          end

        else
          # pdftk returns a line that doesn't start with "Field"
          # It happens when a text field has multiple lines
          last_value + "\n" + line
        end
      end
    end  

    def to_hash
      hash = {}
      ATTRS.each do |attribute|
        hash[attribute] = self.send(attribute)
      end

      hash
    end
  end
end
