require 'spec_helper'
require ::File.expand_path("../../../../lib/galaxy/test_support/pretty_formatter", File.dirname(__FILE__))

describe Galaxy::TestSupport::PrettyFormatter do
  let(:formatted_string) { "#<AClass\nmy_variable = \"a value \",\n \"another\"=0>" }
  let(:simple_class) { "#<AClass>" }
  let(:simple_variable) { "#<AClass \"variable\"=\"value\", something = something else>" }
  let(:simple_variable_expectations) { "#<AClass\n  \"variable\" = \"value\",\n  something = something else\n>" }
  let(:simple_array) { "#<AClass \"array\" = [\"value\", something here, \"\\\"some\\\\thing\\\"\"]>" }
  let(:simple_array_expectations) { "#<AClass\n  \"array\" =\n    [\n      \"value\",\n      something here,\n      \"\\\"some\\\\thing\\\"\"\n    ]\n>" }
  let(:simple_hash) { "#<AClass \"hash\" = {:value => something here, \"\\\"some\\\\thing\\\"\" => a value, symbol: :symbol_also }  >" }
  let(:simple_hash_expectations) { "#<AClass\n  \"hash\" =\n    {\n      :value => something here,\n      \"\\\"some\\\\thing\\\"\" => a value,\n      symbol: :symbol_also\n    }\n>" }

  it "doesn't format a formatted string" do
    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(formatted_string)
    expect(pretty).to be == formatted_string

    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(formatted_string.gsub(/\n/, " "))
    expect(pretty).to_not be == formatted_string
  end

  it "formats a simple class" do
    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(simple_class)
    expect(pretty).to be == simple_class
  end

  it "formats a simple variable" do
    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(simple_variable)
    expect(pretty).to be == simple_variable_expectations
  end

  it "formats a simple class in bigger text" do
    pre_text  = rand(0..1) == 0 ? "#{Faker::Lorem.sentence}\n" : ""
    post_text = rand(0..1) == 0 ? "\n#{Faker::Lorem.sentence}" : ""
    pretty    = Galaxy::TestSupport::PrettyFormatter.format_string("#{pre_text[0..-2]}#{simple_variable}#{post_text[1..-1]}")

    expect(pretty).to be == expectation_in_text(simple_variable_expectations, pre_text, post_text)
  end

  it "formats an array" do
    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(simple_array)
    expect(pretty).to be == simple_array_expectations
  end

  it "formats a simple array in bigger text" do
    pre_text  = rand(0..1) == 0 ? "#{Faker::Lorem.sentence}\n" : ""
    post_text = rand(0..1) == 0 ? "\n#{Faker::Lorem.sentence}" : ""
    pretty    = Galaxy::TestSupport::PrettyFormatter.format_string("#{pre_text[0..-2]}#{simple_array}#{post_text[1..-1]}")

    expect(pretty).to be == expectation_in_text(simple_array_expectations, pre_text, post_text)
  end

  it "formats an hash" do
    pretty = Galaxy::TestSupport::PrettyFormatter.format_string(simple_hash)
    expect(pretty).to be == simple_hash_expectations
  end

  it "formats a simple hash in bigger text" do
    pre_text  = rand(0..1) == 0 ? "#{Faker::Lorem.sentence}\n" : ""
    post_text = rand(0..1) == 0 ? "\n#{Faker::Lorem.sentence}" : ""
    pretty    = Galaxy::TestSupport::PrettyFormatter.format_string("#{pre_text[0..-2]}#{simple_hash}#{post_text[1..-1]}")

    expect(pretty).to be == expectation_in_text(simple_hash_expectations, pre_text, post_text)
  end

  it "formats a known problem string 1" do
    format_value = "#<class @silencers=#<class @silencers=[#<Proc:0x007f8d9f2a15f0@/Users/elittell/.rvm/gems/ruby-1.9.3-p327@homerun/gems/railties-3.2.13/lib/rails/backtrace_cleaner.rb:15>]>, \"HTTP_HO\"=\"HTTP_HO\">"
    pretty       = Galaxy::TestSupport::PrettyFormatter.format_string(format_value)

    expect(pretty).to be == "#<class\n  @silencers =\n    #<class\n      @silencers =\n        [\n          #<Proc:0x007f8d9f2a15f0@/Users/elittell/.rvm/gems/ruby-1.9.3-p327@homerun/gems/railties-3.2.13/lib/rails/backtrace_cleaner.rb:15>\n        ]\n    >,\n  \"HTTP_HO\" = \"HTTP_HO\"\n>"
  end

  (1..1000).to_a.each do |index|
    it "formats a complicated value (#{index})" do
      @seed_value = rand(100000000000000000000000000000000000000..899999999999999999999999999999999999999)
      puts("@seed_value = #{@seed_value}")
      srand(@seed_value)

      test_value, expected_value = create_value(0, [:class, :embedded_class].sample)
      pretty                     = Galaxy::TestSupport::PrettyFormatter.format_string(test_value)
      expect(pretty).to be == expected_value
    end
  end
end

def create_simple_value(type)
  case type
    when :whitespace
      simple_val = " " * rand(1..10)
      simple_val += "\n" * rand(0..10)
      simple_val += "\r" * rand(0..10)
      simple_val = simple_val.split("").sample(100).join("")

    when :value_name_simple, :value_method
      simple_val = Faker::Lorem.word
      simple_val = "#{simple_val}?" if rand(0..1) == 0
      simple_val = "@#{simple_val}" if rand(0..1) == 0

    when :value_name_string, :hash_key_string, :value_string
      simple_val = "\"#{Faker::Lorem.sentence}\""

    when :value_name_complex_string, :value_complex_string, :hash_key_complex_string
      simple_val = "'#{'{}<>[]\"\#~?/`!@#$%^&*()-_=+`'}".split("").sample(rand(5..10)).join("")
      simple_val = "#{simple_val}#{Faker::Lorem.word}".split("").join("")
      simple_val = "#{Faker::Lorem.sentence} #{simple_val}".split(" ").join(" ")
      simple_val = simple_val.gsub(/([\\\"])/, "\\\\\\1")
      simple_val = "\"#{simple_val}\""

    when :value_simple
      case [:number, :float, :date, :date_time, :string, :word].sample
        when :number
          simple_val = rand(-9999999999..9999999999)

        when :float
          simple_val = rand * (10 ** rand(0..15))

        when :date
          simple_val = Date.today + rand(-99999..99999).days

        when :date_time
          simple_val = DateTime.now + rand(-9999999999..9999999999).seconds

        when :string
          simple_val = Faker::Lorem.sentence

        when :word
          simple_val = Faker::Lorem.word
      end

    when :hash_key_symbol
      simple_val = ":#{Faker::Lorem.word}"

    when :hash_key_reversed_symbol
      simple_val = "#{Faker::Lorem.word}:"
  end

  simple_val.to_s
end

def create_value(level, type)
  case type
    when :embedded_class
      pre_value  = rand(0..1) == 0 ? Faker::Lorem.sentence : ""
      post_value = rand(0..1) == 0 ? Faker::Lorem.sentence : ""

      unless pre_value.blank?
        if rand(0..1) == 0
          pre_value << create_simple_value(:whitespace)
        end
      end

      unless post_value.blank?
        if rand(0..1) == 0
          post_value = "#{create_simple_value(:whitespace)}#{post_value}"
        end
      end

      if pre_value.blank?
        val, expected = create_value(level, :class_with_value)
      else
        val, expected = create_value(level + 1, :class_with_value)
      end
      unless post_value.blank?
        post_value = "\n#{post_value}"
      end

      value_val    = "#{pre_value}#{val}#{post_value}"
      value_expect = "#{pre_value.rstrip}#{pre_value.rstrip.blank? ? "" : "\n"}#{expected}\n#{post_value.rstrip}"

      rand(0..5).times do
        pre_value  = rand(0..1) == 0 ? Faker::Lorem.sentence : ""
        post_value = rand(0..1) == 0 ? Faker::Lorem.sentence : ""

        if rand(0..1) == 0
          val = create_simple_value(:whitespace)
          value_val << val
          value_expect << val
        end

        if rand(0..1) == 0
          val = Faker::Lorem.sentence
          value_val << val
          value_expect << val

          if rand(0..1) == 0
            val = create_simple_value(:whitespace)
            value_val << val
            value_expect << val
          end
        end

        if pre_value.blank?
          if rand(0..1) == 0
            pre_value << create_simple_value(:whitespace)
          end
        end

        unless post_value.blank?
          if rand(0..1) == 0
            post_value = "#{create_simple_value(:whitespace)}#{post_value}"
          end
        end
        unless post_value.blank?
          post_value = "\n#{post_value}"
        end

        val, expected = create_value(level + 1, :class)

        if pre_value.rstrip.blank?
          value_expect.rstrip!
        end

        value_val << "#{pre_value}#{val}#{post_value}"
        value_expect << "#{pre_value.rstrip}\n#{expected}\n#{post_value.rstrip}"
      end

      value_expect.rstrip!

    when :class, :class_with_value
      name          = create_simple_value(:value_name_simple)
      value_val     = "\#<#{name}#{" " * rand(1..10)}"
      value_expect  = "#{"  " * level}\#<#{name}"
      append_value  = ""
      append_expect = "\n"

      range_start = type == :class ? 0 : 1

      rand(range_start..5).times do
        name     = create_simple_value([:value_name_complex_string, :value_name_simple, :value_name_string].sample)
        val_type = [:class, :value, :hash, :array].sample
        val_type = :value if level > 4 || rand(0.1) == 0

        case val_type
          when :class, :hash, :array
            val, expected = create_value(level + 2, val_type)

          when :value
            val      = create_simple_value([:value_simple, :value_string, :value_method, :value_complex_string].sample)
            expected = val
        end

        value_val << "#{append_value}#{name}#{create_simple_value(:whitespace)}=#{create_simple_value(:whitespace)}#{val}"
        if val_type == :value
          value_expect << "#{append_expect}#{"  " * (level + 1)}#{name} = #{expected}"
        else
          value_expect << "#{append_expect}#{"  " * (level + 1)}#{name} =\n#{expected}"
        end

        append_value  = ",#{create_simple_value(:whitespace)}"
        append_expect = ",\n"
      end

      unless append_expect.empty?
        append_expect = append_expect[1..-1]
      end
      unless append_expect.empty?
        append_expect << "  " * level
      end

      value_val << ">"

      value_expect << "#{append_expect}>"

    when :hash
      value_val     = "{#{create_simple_value(:whitespace)}"
      value_expect  = "#{"  " * level}{\n"
      append_value  = ""
      append_expect = ""

      rand(1..5).times do
        hash_type = [:hash_key_string, :hash_key_complex_string, :hash_key_symbol, :hash_key_reversed_symbol].sample
        name      = create_simple_value(hash_type)
        val_type  = [:class, :value, :hash, :array].sample
        val_type  = :value if level > 4 || rand(0.1) == 0

        case val_type
          when :class, :hash, :array
            val, expected = create_value(level + 2, val_type)

          when :value
            val      = create_simple_value([:value_simple, :value_string, :value_method, :value_complex_string].sample)
            expected = val
        end

        case hash_type
          when :hash_key_reversed_symbol
            value_val << "#{append_value}#{name}#{create_simple_value(:whitespace)}#{val}"
            if val_type == :value
              value_expect << "#{append_expect}#{"  " * (level + 1)}#{name} #{expected}"
            else
              value_expect << "#{append_expect}#{"  " * (level + 1)}#{name}\n#{expected}"
            end

          else
            value_val << "#{append_value}#{name}#{create_simple_value(:whitespace)}=>#{create_simple_value(:whitespace)}#{val}"
            if val_type == :value
              value_expect << "#{append_expect}#{"  " * (level + 1)}#{name} => #{expected}"
            else
              value_expect << "#{append_expect}#{"  " * (level + 1)}#{name} =>\n#{expected}"
            end
        end

        append_value  = ",#{create_simple_value(:whitespace)}"
        append_expect = ",\n"
      end

      value_val << "}"
      value_expect << "\n#{"  " * level}}"

    when :array
      value_val     = "[#{create_simple_value(:whitespace)}"
      value_expect  = "#{"  " * level}[\n"
      append_value  = ""
      append_expect = ""

      rand(1..5).times do
        val_type = [:class, :value, :hash, :array].sample
        val_type = :value if level > 4 || rand(0.1) == 0

        case val_type
          when :class, :hash, :array
            val, expected = create_value(level + 1, val_type)

          when :value
            val      = create_simple_value([:value_simple, :value_string, :value_method, :value_complex_string].sample)
            expected = "#{"  " * (level + 1)}#{val}"
        end

        value_val << "#{append_value}#{val}"
        value_expect << "#{append_expect}#{expected}"

        append_value  = ",#{create_simple_value(:whitespace)}"
        append_expect = ",\n"
      end

      value_val << "]"
      value_expect << "\n#{"  " * level}]"
  end

  [value_val, value_expect]
end

def expectation_in_text(expected_text, pre_text, post_text)
  expected = "#{pre_text}#{expected_text}#{post_text}"
  expected = expected.gsub("\n", "\n  ") unless pre_text.empty?
  expected = expected.gsub(post_text.gsub("\n", "\n  "), post_text)

  expected
end