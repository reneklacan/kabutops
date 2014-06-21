module Kabutops

  module Extensions

    # inspired by ActiveSupport::Concern

    module Includable
      def append_features(base)
        super
        base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
        base.class_eval(&@_included) if instance_variable_defined?(:@_included)
      end

      def included(base = nil, &block)
        if base.nil?
          @_included = block
        else
          super
        end
      end
    end

  end

end
