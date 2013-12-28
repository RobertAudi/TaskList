module TaskList
  module Exceptions
    class InvalidTaskTypeError < NameError
      def initialize(type: "", message: "")
        if message.empty?
          message = "tl: Invalid task type"

          unless type.empty?
            message << ": #{type}"
          end
        end

        super message
      end
    end
  end
end
