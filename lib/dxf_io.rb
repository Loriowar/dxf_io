require 'dxf_io/version'

module DxfIO
  extend ActiveSupport::Autoload

  autoload :Constants

  autoload :Reader
  autoload :Writer

  autoload :Wrapper
  autoload :Entity
end
