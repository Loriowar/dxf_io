module DxfIO
  module Entity
    class Dimension < Other

      ADDITIONAL_X_COORDINATE_GROUP_NUMS = (12..16).to_a.freeze
      ADDITIONAL_Y_COORDINATE_GROUP_NUMS = (22..26).to_a.freeze
      ADDITIONAL_Z_COORDINATE_GROUP_NUMS = (32..36).to_a.freeze
      ADDITIONAL_START_POINT_GROUP_NUMS = (ADDITIONAL_X_COORDINATE_GROUP_NUMS +
                                           ADDITIONAL_Y_COORDINATE_GROUP_NUMS).freeze

    protected

      def initialize(groups, representation_hash)
        @representation_hash = representation_hash
        super(groups)
      end

    private

      # checking types of coordinate

      def start_point?(group)
        ADDITIONAL_START_POINT_GROUP_NUMS.include?(group.keys.first) || super
      end

      def x_coordinate?(group)
        ADDITIONAL_X_COORDINATE_GROUP_NUMS.include?(group.keys.first) || super
      end

      def y_coordinate?(group)
        ADDITIONAL_Y_COORDINATE_GROUP_NUMS.include?(group.keys.first) || super
      end

    end
  end
end