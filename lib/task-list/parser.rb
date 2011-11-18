module TaskList
  class Parser
    attr_reader :files

    def initialize(*args)
      validate args

      @files = collect args
    end

    private

    # Validate the argument passed to the parser's controller.
    # The argument must be a String and a valid file/folder path (relative or absolute).
    def validate(args)
      raise ArgumentError unless args.is_a?(Array) && args.any?

      args.each do |arg|
        unless arg.is_a? String
          raise ArgumentError, "The argument passed to the parser's constructor must be a String"
        end

        unless File.file?(arg) || File.directory?(arg)
          raise ArgumentError, "The argument passed to the parse's constructor must be either a file or a folder"
        end
      end
    end

    def collect(args)
      files = []
      args.each do |arg|
        %w[**/* **/*.* **/.*].each do |glob|
          files << Dir.glob("#{arg}/#{glob}")
        end
      end

      files.flatten.uniq.delete_if { |file| File.directory?(file) }
    end
  end
end
