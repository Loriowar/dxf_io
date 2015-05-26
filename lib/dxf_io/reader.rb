module DxfIO
  # based on DXF AutoCAD 2008 documentation (http://images.autodesk.com/adsk/files/acad_dxf0.pdf)
  class Reader

    SECTIONS_LIST = DxfIO::Constants::SECTIONS_LIST
    HEADER_NAME = DxfIO::Constants::HEADER_NAME

    def initialize(options)
      if options.is_a? String
        @filename = options
      elsif options.is_a? Hash
        if options[:path].present?
          @filename = options[:path]
        else
          raise ArgumentError, 'options must contain a :path key'
        end
        @encoding = options[:encoding] || 'Windows-1251'
      end
    end

    class << self
      def open(options)
        self.new(options).tap do |reader_instance|
          if block_given?
            yield reader_instance
          end
        end
      end
    end

    ([HEADER_NAME] + SECTIONS_LIST).each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{method.downcase}       # def classes
          run['#{method}']           #   run['CLASSES']
        end                          # end
      EOT
    end

    def run
      @result_hash ||= parse
    end

    alias to_hash run
    alias to_h run

    def rerun
      @result_hash = parse
    end

    def parse(filename = @filename, encoding = @encoding)
      read_flag = "r:#{encoding}:UTF-8"
      fp = File.open(filename, read_flag)
      dxf = {HEADER_NAME => {}}
      SECTIONS_LIST.each do |section_name|
        dxf[section_name] = []
      end
      #
      # main loop
      #
      begin
        while true
          c, v = read_codes(fp)
          break if v == 'EOF'
          if v == 'SECTION'
            c, v = read_codes(fp)
            if v == HEADER_NAME
              hdr = dxf[HEADER_NAME]
              while true
                c, v = read_codes(fp)
                break if v == 'ENDSEC' # or v == "BLOCKS" or v == "ENTITIES" or v == "EOF"
                if c == 9
                  key = v
                  hdr[key] = {}
                else
                  add_att(hdr[key], c, v)
                end
              end # while
            elsif SECTIONS_LIST.include?(v)
              section = dxf[v]
              parse_entities(section, fp)
            end
          end # if in SECTION
        end # main loop
      ensure
        fp.close unless fp.nil?
      end

      dxf
    end

  private

    def parse_entities(section, fp)
      while true
        c, v = read_codes(fp)
        break if v == 'ENDSEC' || v == 'EOF'
        next if c == 999

        if c == 0
          section << [c => v]
        else
          section[-1] << {c => v}
        end
      end # while
    end

    def read_codes(fp)
      c = fp.gets
      return [0, 'EOF'] if c.nil?
      v = fp.gets
      return [0, 'EOF'] if v.nil?
      c = c.to_i
      v.strip!
      v.upcase! if c == 0
      case c
        when 10..59, 110..119, 120..129, 130..139, 140..149, 140..147, 210..239, 460..469, 1010..1059
          v = v.to_f
        when 60..79, 90..99, 170..175, 280..289, 370..379, 380..389, 400..409, 420..429, 440..449, 450..459, 500..409, 1060..1070, 1071
          v = v.to_i
      end

      [c, v]
    end

    def add_att(ent, code, value)
      if ent[code].nil?
        ent[code] = value
      elsif ent[code].is_a? Array
        ent[code] << value
      else
        t = ent[code]
        ent[code] = []
        ent[code] << t
        ent[code] << value
      end
    end

  end
end