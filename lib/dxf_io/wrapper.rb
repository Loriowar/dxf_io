module DxfIO
  class Wrapper

    SECTIONS_LIST = DxfIO::Constants::SECTIONS_LIST
    HEADER_NAME = DxfIO::Constants::HEADER_NAME
    ENTITIES_TYPE_NAME_VALUE_MAPPING = DxfIO::Constants::ENTITIES_TYPE_NAME_VALUE_MAPPING

    def initialize(options)
      if options.is_a? Hash
        if options[:dxf_hash].nil?
          @dxf_hash = options
        else
          @dxf_hash = options[:dxf_hash]
        end
      else
        raise ArgumentError, 'options must be a Hash'
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
        to_proper_class(DxfIO::Entity::Other.new(entity_groups))
      end
    end

  private

    def to_proper_class(entity)
      type_name = ENTITIES_TYPE_NAME_VALUE_MAPPING.invert[entity.type.upcase]
      if type_name.nil? || !DxfIO::Entity.constants.include?(type_name.capitalize.to_sym)
        entity
      else
        entity.public_send("to_#{type_name}")
      end
    end
  end
end
