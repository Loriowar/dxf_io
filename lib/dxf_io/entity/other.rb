module DxfIO
  module Entity
    class Other

      # start point:
      #   x coordinate - 10
      #   y coordinate - 20
      # end point:
      #   x coordinate - 11
      #   y coordinate - 21
      START_POINT_GROUP_NUMS = DxfIO::Constants::START_POINT_GROUP_NUMS
      END_POINT_GROUP_NUMS = DxfIO::Constants::END_POINT_GROUP_NUMS
      X_COORDINATE_GROUP_NUMS = [10, 11].freeze
      Y_COORDINATE_GROUP_NUMS = [20, 21].freeze
      Z_COORDINATE_GROUP_NUMS = [30, 31].freeze

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

      # overall dimensions functions

      # redefined in subclasses
      def bordering_points
        points
      end

      def left_down_point
        DxfIO::Entity::Support::Point.new(bordering_xs.min, bordering_ys.min)
      end

      def height
        (bordering_ys.max - bordering_ys.min).abs
      end

      def width
        (bordering_xs.max - bordering_xs.min).abs
      end

      # coordinates functions

      def xs
        points.collect(&:x)
      end

      def ys
        points.collect(&:y)
      end

      def bordering_xs
        bordering_points.collect(&:x)
      end

      def bordering_ys
        bordering_points.collect(&:y)
      end

      # other properties functions

      # is entity a rectangle figure without rotation
      def frame?
        if points.count < 4
          false
        else
          ((points[0].x == points[3].x) && (points[1].x == points[2].x) &&
           (points[0].y == points[1].y) && (points[2].y == points[3].y)) ||
          ((points[0].y == points[3].y) && (points[1].y == points[2].y) &&
           (points[0].x == points[1].x) && (points[2].x == points[3].x))
          # Alternative checking
          # points[1..-1].each.with_index.inject(true) do |result, (point, index)|
          #   # TODO: need additionally checking on periodical alternation and on direction (clockwise or counter-clockwise)
          #   result && point != points[index] && (point.x == points[index].x || point.y == points[index].y)
          # end
        end
      end

      # moving operations

      # clear alternative for "+" method
      # move all points of Entity on specified vector
      def move_to!(point)
        if point.is_a? DxfIO::Entity::Support::Point
          @groups.each do |group|
            if x_coordinate?(group)
              group[group.keys.first] = group.values.first + point.x
            elsif y_coordinate?(group)
              group[group.keys.first] = group.values.first + point.y
            end
          end
        else
          raise ArgumentError, 'argument must be a DxfIO::Entity::Support::Point'
        end
      end

      # math operations

      # add point to each point onto current entity
      # @warning operator modify current object
      alias + move_to!

      # @warning operator modify current object
      def -(point)
        if point.is_a? DxfIO::Entity::Support::Point
          self + (-point)
        else
          raise ArgumentError, 'argument must be a DxfIO::Entity::Support::Point'
        end
      end

    private

      # @warning experimental method
      def points=(new_points)
        # firstly remove all points from group
        @groups.delete_if do |group|
          (X_COORDINATE_GROUP_NUMS +
           Y_COORDINATE_GROUP_NUMS +
           Z_COORDINATE_GROUP_NUMS).include? group.keys.first
        end
        # secondary insert new points into @groups
        @groups += new_points.collect(&:to_dxf_array)
      end

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
        groups[1..-1].to_a.each.with_index.inject([]) do |result, (group, index)|
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
