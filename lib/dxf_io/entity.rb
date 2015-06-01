module DxfIO
  module Entity
    extend ActiveSupport::Autoload

    autoload :Support
    autoload :Other

    autoload :Ellipse
    autoload :Polyline
    autoload :Arc
    autoload :Circle
    autoload :Dimension
    autoload :Hatch
    autoload :Leader
    autoload :Line
    autoload :Mline
    autoload :Text
    autoload :Mtext
    autoload :Spline
  end
end
