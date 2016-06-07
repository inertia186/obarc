require 'obarc/utils/helper'

module OBarc
  module Utils
    module Exceptions
      using Utils::Helper::ObjectExtensions
      
      class OBarcError < StandardError
        attr_reader :message
        def initialize(message)
          @message = message
        end
      end
      
      class OBarcArgumentError < OBarcError
      end
      
      class MissingArgumentError < OBarcArgumentError
        def initialize(missed_args)
          list = missed_args.map {|arg| arg.to_s} * (', ')
          msg = "#{list} are required."
          super(msg)
        end
      end
      
      class InvalidArgumentError < OBarcArgumentError
        def initialize(invalid_args, msg = nil)
          list = invalid_args.map {|arg| arg.to_s} * (', ')
          msg ||= "#{list} can not be blank."
          super(msg)
        end
      end
    end
  end
end
