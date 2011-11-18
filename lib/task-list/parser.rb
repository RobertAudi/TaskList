module TaskList
  class Parser
    attr_reader :files

    def initialize(*args)
      validate args

      # Get the list of files
      @files = collect args

      # Get the list of valid tasks
      @valid_tasks = get_valid_tasks
    end

    def parse
      puts "Parsing..."
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

    # Take the args, which are files/folders list,
    # and create a list of all the files to parse
    def collect(args)
      files = []
      args.each do |arg|
        %w[**/* **/*.* **/.*].each do |glob|
          files << Dir.glob("#{arg}/#{glob}")
        end
      end

      files.flatten.uniq.delete_if { |file| File.directory?(file) }
    end

    # Get the valid tasks and their regex
    # from the config/valid_tasks.yml YAML file
    def get_valid_tasks
      tasks = {}

      shit = YAML::load(File.open("config/valid_tasks.yml"))
      shit.each do |crap|
        crap.each do |task, regex|
          tasks[task] = regex
        end
      end

      tasks
    end
  end
end
