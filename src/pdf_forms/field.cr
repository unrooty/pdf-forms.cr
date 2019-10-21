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

    @name : String | Nil
    @type : String | Nil
    @options : Array(String) = [] of String
    @flags : String | Nil
    @justification : String | Nil
    @value : String | Nil
    @value_default : String | Nil
    @name_alt : String | Nil
    @max_length : String | Nil
    @additional_attributes = {} of String => String

    def initialize(field_description)
      assing_variables(build_attributes(field_description))
    end

    def to_hash
      hash = {} of String => String
      ATTRS.each do |attribute|
        hash[attribute] = self.send(attribute)
      end

      hash
    end

    private def build_attributes(field_description) : Array(Hash(String, String))
      last_value = ""

      Array(Hash(String, String)).new.tap do |array_of_attributes|
        field_description.each_line do |line|
          if line.chomp =~ /^Field([A-Za-z]+):\s+(.*)/
            _, key, value = $~

            if key == "StateOption"
              @options << value
            else
              last_value = value.chomp
              key = key.split(/(?=[A-Z])/).map(&.downcase).join('_')

              array_of_attributes << { key => value }
              # dynamically add in fields that we didn't anticipate in ATTRS
              # unless self.responds_to?(method_name)
              #   proc = Proc.new { instance_variable_get("@#{key}".to_sym) }
              #   self.class.send(:define_method, key.to_sym, proc)
              # end
            end

          else
            # pdftk returns a line that doesn't start with "Field"
            # It happens when a text field has multiple lines
            last_value + "\n" + line
          end
        end
      end
    end

    private def assing_variables(array_of_attributes : Array(Hash(String, String)))
      array_of_attributes.each do |attribute|
        attribute.each do |name, value|
          assign_variable(name, value)
        end
      end
    end

    private def assign_variable(name : String | Symbol, value : String)
      return @additional_attributes[name] = value unless variable_defined?(name)

      {% for ivar in @type.instance_vars %}
        if {{ivar.id.stringify}} == name
          if value.is_a?({{ ivar.type.id }})
            @{{ivar}} = value
          else
            raise "Invalid type #{value.class} for {{ivar.id.symbolize}} (expected {{ ivar.type.id }})"
          end
        end
      {% end %}
    end

    private def variable_defined?(field_name)
      {{ @type.instance_vars.map(&.name.stringify) }}.includes?(field_name)
    end
  end
end
