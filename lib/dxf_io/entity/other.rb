module DxfIO
  module Entity
    class Other

      # start point:
      #   x coordinate - 10
      #   y coordinate - 20
      # end point:
      #   x coordinate - 11
      #   y coordinate - 21
      START_POINT_GROUP_NUMS = [10, 20].freeze
      END_POINT_GROUP_NUMS = [11, 21].freeze
      X_COORDINATE_GROUP_NUMS = [10, 11].freeze
      Y_COORDINATE_GROUP_NUMS = [20, 21].freeze

      TYPE_NAME_VALUE_MAPPING = DxfIO::Constants::ENTITIES_TYPE_NAME_VALUE_MAPPING

      GROUP_CODES = {type: 0}.freeze

      def initialize(groups)
        if groups.is_a? Array
          @groups = groups
        else
          raise ArgumentError, 'groups must be an Array'
        end
      end

      def to_h
        @representation_hash ||=
            @groups.inject({}) do |h, group|
              group_value = group.values.first
              group_values = h[group.keys.first]
              if group_values.nil?
                h[group.keys.first] = group_value
              elsif group_values.is_a? Array
                h[group.keys.first] << group_value
              else
                h[group.keys.first] = [group_values, group_value]
              end
              h
            end
      end

      alias to_hash to_h

      def to_a
        @groups
      end

      GROUP_CODES.each_pair do |method_name, group_code|
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def #{method_name}                       # def type
            to_h[#{group_code}]                    #   to_h[0]
          end                                      # end
        EOT
      end

      TYPE_NAME_VALUE_MAPPING.each_pair do |method_name, type_value|
        class_eval <<-EOT, __FILE__, __LINE__ + 1
          def #{method_name}?                                             # def ellipse?
            type == '#{type_value}'                                       #   type == 'ELLIPSE'
          end                                                             # end

          def to_#{method_name}                                           # def to_ellise
            DxfIO::Entity::#{method_name.capitalize}.new(@groups, to_h)   #   DxfIO::Entity::Ellipse.new(@groups, to_h)
          end                                                             # end
        EOT
      end

      def points
        groups = validate_point_groups(point_groups)
        groups[1..-1].each.with_index.inject([]) do |result, (group, index)|
          if (index % 2) == 0
            type = start_point?(group) ? :start : :end
            result << DxfIO::Entity::Support::Point.new(groups[index].values.first,
                                                        group.values.first,
                                                        type: type)
          else
            result
          end
        end
      end

      # redefined in subclasses
      def bordering_points
        points
      end

      def xs
        points.collect(&:x)
      end

      def ys
        points.collect(&:y)
      end

    private

      # checking  types of coordinate

      def start_point?(group)
        START_POINT_GROUP_NUMS.include? group.keys.first
      end

      def end_point?(group)
        END_POINT_GROUP_NUMS.include? group.keys.first
      end

      def x_coordinate?(group)
        X_COORDINATE_GROUP_NUMS.include? group.keys.first
      end

      def y_coordinate?(group)
        Y_COORDINATE_GROUP_NUMS.include? group.keys.first
      end

      # points selection

      def point_groups
        @groups.inject([]) do |h, group|
          if x_coordinate?(group) || y_coordinate?(group)
            h << group
          else
            h
          end
        end
      end

      # reject invalid sequences of coordinate groups
      def validate_point_groups(groups)
        groups[1..-1].each.with_index.inject([]) do |result, (group, index)|
          if y_coordinate?(group)
            if x_coordinate?(groups[index]) &&
                ( (start_point?(group) && start_point?(groups[index])) ||
                  (end_point?(group) && end_point?(groups[index]))
                )
              result << groups[index]
              result << group
            end
          end

          result
        end
      end

    end
  end
end
