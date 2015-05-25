module DxfIO
  module Entity
    class Line < Other

    protected

      def initialize(groups, representation_hash)
        @representation_hash = representation_hash
        super(groups)
      end

    end
  end
end