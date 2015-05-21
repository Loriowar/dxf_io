module DxfIO
  class Writer
    require 'fileutils'

    SECTIONS_LIST = %w(CLASSES TABLES BLOCKS ENTITIES OBJECTS THUMBNAILIMAGES).freeze

    def initialize(options)
      if options[:dxf_hash].present? && options[:path].present?
        @dxf_hash = options[:dxf_hash]
        @filename = options[:path]
      else
        raise ArgumentError, 'options must contain :dxf_hash and :path keys'
      end
      @encoding = options[:encoding] || 'Windows-1251'
      @delimiter = options[:delimiter] || "\r\n"
    end

    def write
      folder_path = @filename.split('/')[0..-2].join('/')
      FileUtils.mkdir_p(folder_path)
      fp = File.open(@filename, "w:#{@encoding}")
      begin
        file_wrap(fp) do
          @dxf_hash.inject('') do |sections_content, (section_name, section_content)|
            sections_content << section_wrapper_content(section_name) do
              if header_section?(section_name)
                header_content(section_content)
              else
                other_section_content(section_content)
              end
            end
          end
        end
      ensure
        fp.close unless fp.nil?
      end
    end

  private

    # helpers

    def header_section?(section_name)
      section_name.downcase == 'header'
    end

    # wrappers

    # file format:
    #   ... file content ...
    #   0
    #   EOF
    def file_wrap(fp, &block)
      file_end = "0#{@delimiter}EOF#{@delimiter}"

      fp.write(block.call)
      fp.write(file_end)
    end

    # section format:
    #   0
    #   SECTION
    #   2
    #   HEADER
    #   ... section content ...
    #   0
    #   ENDSEC
    def section_wrap(fp, section_name, &block)
      section_begin = "0#{@delimiter}SECTION#{@delimiter}2#{@delimiter}#{section_name.upcase}#{@delimiter}"
      section_end = "0#{@delimiter}ENDSEC#{@delimiter}"

      fp.write(section_begin)
      fp.write(block.call)
      fp.write(section_end)
    end

    # header format:
    #   9
    #   $<variable>
    #   <group code>
    #   <value>
    def header_writer(fp, variables)
      variables.each_pair do |variable, groups|
        fp.write("9#{@delimiter}#{'$' if variable[0] != '$'}#{variable}#{@delimiter}")
        groups.each_pair do |group_code, value|
          fp.write("#{group_code}#{@delimiter}#{try_to_upcase_exponent(value)}#{@delimiter}")
        end
      end
    end

    # content constructors

    def file_content(&block)
      file_end = "0#{@delimiter}EOF#{@delimiter}"

      "#{block.call}#{file_end}"
    end

    def section_wrapper_content(section_name, &block)
      section_begin = "0#{@delimiter}SECTION#{@delimiter}2#{@delimiter}#{section_name.upcase}#{@delimiter}"
      section_end = "0#{@delimiter}ENDSEC#{@delimiter}"

      "#{section_begin}#{block.call}#{section_end}"
    end

    def header_content(variables)
      variables.inject('') do |result, (variable, groups)|
        variable_part = "9#{@delimiter}#{'$' if variable[0] != '$'}#{variable}#{@delimiter}"
        result << groups.inject(variable_part) do |group_result, (group_code, value)|
          group_result << "#{group_code}#{@delimiter}#{try_to_upcase_exponent(value)}#{@delimiter}"
        end
      end
    end

    def other_section_content(variables)
      variables.inject('') do |result, groups|
        result << groups.inject('') do |group_result, group|
          group_result << "#{group.keys.first}#{@delimiter}#{try_to_upcase_exponent(group.values.first)}#{@delimiter}"
        end
      end
    end

    # formatting

    # replace exponential notation by decimal notation and remove redundant zeros in the end
    def try_to_decimal_fraction(num)
      if num.is_a? Float
        ('%.25f' % num).to_s.sub(/0+$/, '')
      else
        num
      end
    end

    def try_to_upcase_exponent(num)
      if num.is_a? Float
        num.to_s.sub('e', 'E')
      else
        num
      end
    end
  end
end