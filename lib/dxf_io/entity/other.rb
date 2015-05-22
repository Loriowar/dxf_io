module DxfIO
  module Entity
    class Other
      def initialize(groups)
        if groups.is_a? Array
          @groups = groups
        else
          raise ArgumentError, 'groups must be an Array'
        end
      end

      def to_h
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

    end
  end
end
