module DxfIO
  module Entity
    class Ellipse < Other
      ADDITIONAL_GROUP_CODES = {minor_to_major_ration: 40}.freeze

      ADDITIONAL_GROUP_CODES.each_pair do |method_name, group_code|
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def #{method_name}                       # def radius
            to_h[#{group_code}]                    #   to_h[40]
          end                                      # end
        EOT
      end

      def center
        points.find(&:start?)
      end

      def major_axis_endpoint_vector
        points.find(&:end?)
      end

      def minor_axis_endpoint_vector
        major_axis_endpoint_vector.rotate_90 * minor_to_major_ration
      end

      def major_axis_points
        [center + major_axis_endpoint_vector, center + major_axis_endpoint_vector.rotate_180]
      end

      def minor_axis_points
        [center + minor_axis_endpoint_vector, center + minor_axis_endpoint_vector.rotate_180]
      end

      def bordering_points
        major_axis_points + minor_axis_points
      end

    protected

      def initialize(groups, representation_hash)
        @representation_hash = representation_hash
        super(groups)
      end
    end
  end
end