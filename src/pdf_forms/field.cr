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
    @fields_attributes : Hash(String, String | Array(String)) = Hash(String, String | Array(String)).new

    getter name : String = ""
    getter type : String = ""
    getter options : Array(String) = [] of String
    getter flags : String = ""
    getter justification : String = ""
    getter value : String = ""
    getter value_default : String = ""
    getter name_alt : String = ""
    getter max_length : String = ""
    getter additional_attributes : Hash(String, String | Array(String)) = {} of String => String | Array(String)

    def initialize(field_description : String)
      @field_description = field_description

      build_attributes
      assing_variables
    end

    def to_hash : Hash(String, String | Array(String))
      @fields_attributes
    end

    private def build_attributes
      last_key = ""
      last_value = ""

      @field_description.each_line do |line|
        if line.chomp.match(/^Field([A-Za-z]+)?:(\s+(.*)|$)/)
          _, key, value = $~

          if key == "StateOption"
            @options.push(value.lstrip)
          else
            last_key = key.split(/(?=[A-Z])/).map(&.downcase).join('_')
            last_value = value.chomp.lstrip

            assign_attribute(last_key, last_value)
          end
        else
          # pdftk returns a line that doesn't start with "Field"
          # It happens when a text field has multiple lines
          last_value += "\n" + line

          assign_attribute(last_key, last_value) unless last_key.blank?
        end
      end

      assign_attribute("options", @options)
    end

    private def assing_variables
      @fields_attributes.each do |name, value|
        assign_variable(name, value)
      end
    end

    private def assign_variable(name : String, value : String | Array(String))
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

    private def variable_defined?(field_name : String)
      {{ @type.instance_vars.map(&.name.stringify) }}.includes?(field_name)
    end

    def assign_attribute(key : String, value : String | Array(String))
      @fields_attributes[key] = value
    end
  end
end
