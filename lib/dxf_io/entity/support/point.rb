module DxfIO
  module Entity
    module Support
      class Point

        TYPES = %i(start end).freeze

        attr_reader :x, :y

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
      end
    end
  end
end