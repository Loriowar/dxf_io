module DxfIO
  # based on DXF AutoCAD 2008 documentation (http://images.autodesk.com/adsk/files/acad_dxf0.pdf)
  class Reader

    SECTIONS_LIST = %w(CLASSES TABLES BLOCKS ENTITIES OBJECTS THUMBNAILIMAGES).freeze

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

    (['HEADER'] + SECTIONS_LIST).each do |method|
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
      dxf = {'HEADER' => {}}
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
            if v == 'HEADER'
              hdr = dxf['HEADER']
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
      last_ent = nil
      last_code = nil
      while true
        c, v = read_codes(fp)
        break if v == 'ENDSEC' or v == 'EOF'
        next if c == 999
        # LWPOLYLINE seems to break the rule that we can ignore the order of codes.
        if last_ent == 'LWPOLYLINE'
          if c == 10
            section[-1][42] ||= []
            # Create default 42
            add_att(section[-1], 42, 0.0)
          end
          if c == 42
            # update default
            section[-1][42][-1] = v
            next
          end
        end
        if c == 0
          last_ent = v
          section << {c => v}
        else
          add_att(section[-1], c, v)
        end
        last_code = c
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
      # Initially, I thought each code mapped to a single value. Turns out
      # a code can be a list of values.
      if ent.nil? && $JFDEBUG
        p caller
        p code
        p value
      end
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