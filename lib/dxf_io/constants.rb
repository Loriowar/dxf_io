module DxfIO
  module Constants
    SECTIONS_LIST = %w(CLASSES TABLES BLOCKS ENTITIES OBJECTS THUMBNAILIMAGES).freeze
    HEADER_NAME = 'HEADER'.freeze

    WRITER_STRATEGY = %i(memory disk).freeze
  end
end
