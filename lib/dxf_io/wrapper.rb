module DxfIO
  class Wrapper

    SECTIONS_LIST = DxfIO::Constants::SECTIONS_LIST
    HEADER_NAME = DxfIO::Constants::HEADER_NAME
    ENTITIES_TYPE_NAME_VALUE_MAPPING = DxfIO::Constants::ENTITIES_TYPE_NAME_VALUE_MAPPING

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
