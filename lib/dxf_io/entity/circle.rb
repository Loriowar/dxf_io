module DxfIO
  module Entity
    class Circle < Other
      ADDITIONAL_GROUP_CODES = {radius: 40}.freeze

      ADDITIONAL_GROUP_CODES.each_pair do |method_name, group_code|
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def #{method_name}                       # def radius
            to_h[#{group_code}]                    #   to_h[40]
          end                                      # end
        EOT
      end

      def center
        points.first
      end

      def bordering_points
        [ center + [radius, 0],
          center + [0, radius],
          center - [radius, 0],
          center - [0, radius] ]
      end

      protected

      def initialize(groups, representation_hash)
        @representation_hash = representation_hash
        super(groups)
      end
    end
  end
end