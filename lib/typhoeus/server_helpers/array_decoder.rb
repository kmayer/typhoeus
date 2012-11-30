#
# Typhoeus encodes arrays as hashes {'0' => v0, '1' => v1, .., 'n' => vN }
#
# To fix this in your Rails server your should:
# in Gemfile:
#     gem 'typhoeus'
#
# in application_controller.rb:
#
#    require 'typhoeus/server_helpers/array_decoder'
#    class ApplicationController < ActionController::Base
#      include Typhoeus::ServerHelpers::ArrayDecoder
#      before_filter :decode_typhoeus_arrays
#    end
#
module Typhoeus
  module ServerHelpers
    module ArrayDecoder

      ##
      # For a cleaner usage in your Rails Controller
      #
      # @example
      #     class ApplicationController
      #       before_filter :decode_typhoeus_arrays
      #       ....
      #
      def decode_typhoeus_arrays
        deep_decode!(params)
      end

      # Recursively decodes Typhoeus encoded arrays in given hash.
      #
      # @param hash [Hash]. This hash will be modified!
      #
      # @author Dwayne Macgowan
      # @version 0.5.4
      #
      # @return [Hash] decoded array
      def deep_decode!(hash)
        return hash unless hash.is_a?(Hash)
        hash.each_pair do |key,value|
          if value.is_a?(Hash)
            deep_decode!(value)
            hash[key] = value.decode_typhoeus_array
          end
        end
        hash
      end

      def deep_decode(hash)
        deep_decode!(hash.dup)
      end
    end
  end
end

# Add Hash#is_typhoeus_array? and Hash#decode_typhoeus_array methods
class Hash

  # Checks if hash is an Array encoded as a hash.
  # Specifically will check for the hash to have this form: {'0' => v0, '1' => v1, .., 'n' => vN }
  # @return [TrueClass]
  def im_an_array_typhoeus_encoded?
    return false if self.empty?
    self.keys.sort == (0...self.keys.size).map{|i|i.to_s}
  end

  # If the hash is an array encoded by typhoeus an array is returned
  # else the self is returned
  #
  # @see im_an_array_typhoeus_encoded?
  #
  # @return [Array/Hash]
  def decode_typhoeus_array
    if self.im_an_array_typhoeus_encoded?
      Hash[self.sort].values
    else
      self
    end
  end
end