module DxfIO
  module Constants
    SECTIONS_LIST = %w(CLASSES TABLES BLOCKS ENTITIES OBJECTS THUMBNAILIMAGES).freeze
    HEADER_NAME = 'HEADER'.freeze

    WRITER_STRATEGY = %i(memory disk).freeze

    START_POINT_GROUP_NUMS = [10, 20].freeze
    END_POINT_GROUP_NUMS = [11, 21].freeze

    ENTITIES_TYPE_NAME_VALUE_MAPPING = {ellipse: 'ELLIPSE',
                                        polyline: 'LWPOLYLINE',
                                        arc: 'ARC',
                                        circle: 'CIRCLE',
                                        dimension: 'DIMENSION',
                                        hatch: 'HATCH',
                                        leader: 'LEADER',
                                        line: 'LINE',
                                        mline: 'MLINE',
                                        text: 'TEXT',
                                        mtext: 'MTEXT',
                                        spline: 'SPLINE'}.freeze
  end
end
