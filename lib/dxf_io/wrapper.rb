module DxfIO
  class Wrapper

    SECTIONS_LIST = DxfIO::Constants::SECTIONS_LIST
    HEADER_NAME = DxfIO::Constants::HEADER_NAME

    def initialize(options)
      if options[:dxf_hash].present?
        @dxf_hash = options[:dxf_hash]
      else
        raise ArgumentError, 'options must contain :dxf_hash key'
      end
    end

    SECTIONS_LIST.each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{method.downcase}                  # def classes
          fetch_entities('#{method}')           #   fetch_entities('CLASSES')
        end                                     # end
      EOT
    end

    def fetch_entities(group_name)
      @dxf_hash[group_name.upcase].collect do |entity_groups|
        DxfIO::Entity::Other.new(entity_groups)
      end
    end

  end
end
