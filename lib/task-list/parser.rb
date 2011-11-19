module TaskList
  class Parser
    attr_reader :files, :valid_tasks, :tasks

    def initialize(*args)
      validate args

      # Get the list of files
      @files = collect args

      # Get the list of valid tasks
      @valid_tasks = get_valid_tasks

      # Get excluded folders
      @excluded_folders = get_excluded_folders

      # Initialize the tasks hash
      @tasks = initialize_tasks_hash
    end

    # Parse all the collected files to find tasks
    # and populate the @tasks hash
    def parse(type = nil)
      unless type.nil? || (type.is_a?(Symbol) && @valid_tasks.has_key?(type))
        raise ArgumentError
      end

      @files.each do |file|
        parsef file, type
      end
    end

    def print
      @tasks.each do |type, tasks|
        unless tasks.empty?
          puts "\n#{type}:\n-----\n"
          tasks.each do |task|
            puts task[:task]
            # CHANGED: Colors are now always enabled.
            # Without colors the output is unreadable
            puts "  \e[30m\e[1mline #{task[:line_number]} in #{task[:file]}\e[0m"
          end
        end
      end
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

    # Get the list of excluded folders and their regex
    # from the config/excluded_folders.yml YAML file
    def get_excluded_folders
      YAML::load(File.open("config/excluded_folders.yml"))
    end

    # Initialize the tasks hash
    def initialize_tasks_hash
      tasks = {}
      @valid_tasks.each do |task, regex|
        tasks[task] = []
      end

      tasks
    end

    # Parse a file to find tasks
    def parsef(file, type = nil)
      # Don't parse files that are in excluded folders!
      @excluded_folders.each do |regex|
        return if file =~ /#{regex}/
      end

      valid_tasks = (type.nil?) ? @valid_tasks : @valid_tasks.select { |k,v| k == type }

      File.open(file, "r") do |f|
        line_number = 1
        while line = f.gets
          valid_tasks.each do |type, regex|
            result = line.match regex
            unless result.nil?
              task = {
                file: file,
                line_number: line_number,
                task: result.to_a.last
              }

              @tasks[type] << task
            end
          end

          line_number += 1
        end
      end
    end
  end
end
