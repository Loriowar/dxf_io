module DxfIO
  class Writer
    require 'fileutils'

    SECTIONS_LIST = DxfIO::Constants::SECTIONS_LIST
    HEADER_NAME = DxfIO::Constants::HEADER_NAME
    STRATEGY = DxfIO::Constants::WRITER_STRATEGY

    def initialize(options)
      # TODO: replace instance variables to hash with options
      # default options
      @encoding = 'Windows-1251'
      @delimiter = "\r\n"
      @strategy = STRATEGY.first
      @dxf_hash = {}

      if options.is_a? String
        @filename = options
      elsif options.is_a? Hash
        @dxf_hash = options[:dxf_hash] if options.has_key? :dxf_hash
        @filename = options[:path] if options.has_key? :path
        @encoding = options[:encoding] if options.has_key? :encoding
        @delimiter = options[:delimiter] if options.has_key? :delimiter
        @strategy = options[:strategy] if options.has_key? :strategy && STRATEGY.include?(options[:strategy])
      else
        raise ArgumentError, 'options must be String or Hash with :path key'
      end
    end

    class << self
      def open(options)
        self.new(options).tap do |writer_instance|
          if block_given?
            yield writer_instance
          end
        end
      end
    end

    # construct dxf content in memory and write all in file at once
    def write_through_memory(dxf_hash = @dxf_hash)
      file_stream do |fp|
        fp.write(
            file_content do
              dxf_hash.inject('') do |sections_content, (section_name, section_content)|
                sections_content << section_wrapper_content(section_name) do
                  if header_section?(section_name)
                    header_content(section_content)
                  else
                    other_section_content(section_content)
                  end
                end
              end
            end
        )
      end
    end

    # write dxf file directly on disk without temporary usage of memory for content
    def write_through_disk(dxf_hash = @dxf_hash)
      file_stream do |fp|
        file_wrap(fp) do
          dxf_hash.each_pair do |section_name, section_content|
            section_wrap(fp, section_name) do
              if header_section?(section_name)
                header_wrap(fp, section_content)
              else
                other_section_wrap(fp, section_content)
              end
            end
          end
        end
      end
    end

    def run(dxf_hash = @dxf_hash)
      if @strategy == :memory
        write_through_memory(dxf_hash)
      elsif @strategy == :disk
        write_through_disk(dxf_hash)
      else
        raise ArgumentError, ':strategy has invalid value; allowed only [:memory, :disk]'
      end
    end

    alias write_hash run

  private

    # work with file

    def file_stream(&block)
      folder_path = @filename.split('/')[0..-2].join('/')
      FileUtils.mkdir_p(folder_path)
      fp = File.open(@filename, "w:#{@encoding}")
      begin
        block.call(fp)
      ensure
        fp.close unless fp.nil?
      end
    end

    # helpers

    def header_section?(section_name)
      section_name.upcase == HEADER_NAME
    end

    # wrappers

    # file format:
    #   ... file content ...
    #   0
    #   EOF
    def file_wrap(fp, &block)
      file_end = "0#{@delimiter}EOF#{@delimiter}"

      block.call
      fp.write(file_end)
    end

    # section format:
    #   0
    #   SECTION
    #   2
    #   <section_name>
    #   ... section content ...
    #   0
    #   ENDSEC
    def section_wrap(fp, section_name, &block)
      section_begin = "0#{@delimiter}SECTION#{@delimiter}2#{@delimiter}#{section_name.upcase}#{@delimiter}"
      section_end = "0#{@delimiter}ENDSEC#{@delimiter}"

      fp.write(section_begin)
      block.call
      fp.write(section_end)
    end

    # header format:
    #   9
    #   $<variable>
    #   <group code>
    #   <value>
    def header_wrap(fp, variables)
      variables.each_pair do |variable, groups|
        fp.write("9#{@delimiter}#{'$' if variable[0] != '$'}#{variable}#{@delimiter}")
        groups.each_pair do |group_code, value|
          fp.write("#{group_code}#{@delimiter}#{try_to_upcase_exponent(value)}#{@delimiter}")
        end
      end
    end

    # other section format:
    #   <group code>
    #   <value>
    def other_section_wrap(fp, variables)
      variables.each do |groups|
        groups.each do |group|
          fp.write("#{group.keys.first}#{@delimiter}#{try_to_upcase_exponent(group.values.first)}#{@delimiter}")
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