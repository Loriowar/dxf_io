module DxfIO
  module Entity
    class Arc < Other
      ADDITIONAL_GROUP_CODES = {radius: 40,
                                start_angle: 50,
                                end_angle: 51}.freeze

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
        [point_by_angle(start_angle,
                        point_type: :start),
         point_by_angle(end_angle,
                        point_type: :end)]
      end

    protected

      def initialize(groups, representation_hash)
        @representation_hash = representation_hash
        super(groups)
      end

    private

      def point_by_angle(angle, point_type: :start)
        DxfIO::Entity::Support::Point.new(center.x + radius * Math::cos(angle),
                                          center.y + radius * Math::sin(angle),
                                          type: point_type)
      end

    end
  end
end