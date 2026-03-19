module ServiceObject
  extend ActiveSupport::Concern

  included do
    def self.call(**args)
      new(**args).call
    end

    def call
      raise NotImplementedError, "Subclasses must implement the call method"
    end
  end

  private

  class_methods do
    def arguments(*required_arguments, **optional_arguments)
      parameters = required_arguments + optional_arguments.keys
      attr_reader *parameters
      private *parameters

      setup = Module.new do
        define_method(:initialize) do |**args|
          missing_arguments = required_arguments - args.keys
          raise ArgumentError, "Missing required arguments: #{missing_arguments.join(", ")}" if missing_arguments.any?

          invalid_args = args.keys - parameters
          raise ArgumentError, "Invalid arguments: #{invalid_args.join(", ")}" if invalid_args.any?

          optional_arguments.merge(args).each do |parameter, value|
            instance_variable_set("@#{parameter}", value)
          end
        end
      end

      prepend setup
    end
  end
end
