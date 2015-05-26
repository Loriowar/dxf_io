module DxfIO
  module Entity
    module Support
      class Point

        START_POINT_GROUP_NUMS = DxfIO::Constants::START_POINT_GROUP_NUMS
        END_POINT_GROUP_NUMS = DxfIO::Constants::END_POINT_GROUP_NUMS
        TYPES = %i(start end).freeze

        attr_reader :x, :y, :type

        def initialize(x, y, options = {})
          @x, @y = x, y
          @type = TYPES.include?(options[:type]) ? options[:type] : TYPES.first
        end

        def start?
          @type == :start
        end

        def end?
          @type == :end
        end

        def to_a
          [@x, @y]
        end

        def to_h
          {x: @x, y: @y}
        end

        def to_dxf_array
          if start?
            [{START_POINT_GROUP_NUMS.first => @x}, {START_POINT_GROUP_NUMS.last => @y}]
          elsif end?
            [{END_POINT_GROUP_NUMS.first => @x}, {END_POINT_GROUP_NUMS.last => @y}]
          end
        end

        # eq operations

        def ==(point)
          to_a == point.to_a
        end

        # math operations

        # unary

        def -@
          self.class.new(-@x, -@y, type: @type)
        end

        # binary

        def +(point)
          if point.is_a? self.class
            self.class.new(@x + point.x,
                           @y + point.y,
                           type: @type == point.type ? @type : :start)
          elsif point.is_a? Array
            self.class.new(@x + point[0],
                           @y + point[1],
                           type: @type)
          else
            raise ArgumentError, 'point must be an Array or a DxfIO::Entity::Support::Point'
          end
        end

        def -(point)
          if point.is_a? self.class
            self - point
          elsif point.is_a? Array
            self + point.map(&:-@)
          else
            raise ArgumentError, 'point must be an Array or a DxfIO::Entity::Support::Point'
          end
        end

        def *(num)
          if num.is_a? Numeric
            self.class.new(@x * num,
                           @y * num,
                           type: @type)
          else
            raise ArgumentError, 'argument must be Numeric'
          end
        end

        def /(num)
          if num.is_a? Numeric
            self.class.new(@x / num,
                           @y / num,
                           type: @type)
          else
            raise ArgumentError, 'argument must be Numeric'
          end
        end

        # geometrical operation (supposed what point is a vector from zero)

        def rotate_90
          self.class.new(@y, -@x, type: @type)
        end

        def rotate_180
          -self
        end

      end
    end
  end
end