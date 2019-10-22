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

    setter field_description : String

    getter name : String = ""
    getter type : String  = ""
    getter options : Array(String) = [] of String
    getter flags : String = ""
    getter justification : String  = ""
    getter value : String  = ""
    getter value_default : String  = ""
    getter name_alt : String  = ""
    getter max_length : String  = ""
    getter additional_attributes : Hash(String, String)  = {} of String => String

    def initialize(field_description : String)
      @field_description = field_description

      assing_variables(build_attributes)
    end

    def to_hash
      build_attributes
    end

    private def build_attributes : Hash(String, String)
      last_value = ""

      Hash(String, String).new.tap do |attributes|
        @field_description.each_line do |line|
          if line.chomp =~ /^Field([A-Za-z]+):\s+(.*)/
            _, key, value = $~

            if key == "StateOption"
              @options << value
            else
              last_value = value.chomp
              key = key.split(/(?=[A-Z])/).map(&.downcase).join('_')

              attributes[key] = value
            end
          else
            # pdftk returns a line that doesn't start with "Field"
            # It happens when a text field has multiple lines
            last_value + "\n" + line
          end
        end
      end
    end

    private def assing_variables(attributes : Hash(String, String))
      attributes.each do |name, value|
        assign_variable(name, value)
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
