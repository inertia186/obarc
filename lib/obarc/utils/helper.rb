module OBarc
  module Utils
    module Helper
      module ObjectExtensions
        refine Hash do
          def compact
            self.select { |_, value| !value.nil? }
          end
          
          def slice(*keys)
            keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
            keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
          end
        end
      end
    end
  end
end
