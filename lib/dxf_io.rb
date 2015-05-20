require 'dxf_io/version'

module DxfIO
  extend ActiveSupport::Autoload

  autoload :Reader
  autoload :Writer
end
