require "find"

module TaskList
  class Parser
    attr_reader :files, :tasks

    def initialize(arguments: [], options: {})
      @type = options[:type].upcase if options[:type]
      # @files = fuzzy_find_files queries: arguments unless arguments.empty?
      @files = fuzzy_find_files queries: arguments
      @tasks = {}
      VALID_TASKS.each { |t| @tasks[t.to_sym] = [] }
    end

    # Parse all the collected files to find tasks
    # and populate the tasks hash
    def parse!
      unless @type.nil? || VALID_TASKS.include?(@type)
        raise TaskList::Exceptions::InvalidTaskTypeError.new type: @type
      end

      @files.each { |f| parsef! file: f }
    end

    def print!
      @tasks.each do |type, tasks|
        unless tasks.empty?
          puts "#{type}:\n#{'-' * (type.length + 1)}\n"

          tasks.each do |task|
            puts task[:task]
            puts "  \e[30m\e[1mline #{task[:line_number]} in #{task[:file]}\e[0m"
          end

          puts
        end
      end
    end

    private

    def fuzzy_find_files(queries: [])
      patterns = regexify queries

      paths = []
      # FIXME: Search in the root of a project if in a git repo
      Find.find('.') do |path|
        paths << path unless FileTest.directory?(path)
      end

      paths.map! { |p| p.gsub /\A\.\//, "" }

      EXCLUDED_DIRECTORIES.each do |d|
        paths.delete_if { |p| p =~ /\A#{Regexp.escape(d)}/ }
      end

      EXCLUDED_EXTENSIONS.each do |e|
        paths.delete_if { |p| File.file?(p) && File.extname(p) =~ /\A#{Regexp.escape(e)}/ }
      end

      EXCLUDED_GLOBS.each do |g|
        paths.delete_if { |p| p =~ /#{unglobify(g)}/ }
      end

      if queries.empty?
        paths
      else
        results = []

        patterns.each do |pattern|
          paths.each do |path|
            matches = path.match(/#{pattern}/).to_a

            results << path unless matches.empty?
          end
        end

        results
      end
    end

    def regexify(queries)
      patterns = []

      queries.each do |query|
        if query.include?("/")
          pattern = query.split("/").map { |p| p.split("").join(")[^\/]*?(").prepend("[^\/]*?(") + ")[^\/]*?" }.join("\/")
          pattern << "\/" if query[-1] == "/"
        else
          pattern = query.split("").join(").*?(").prepend(".*?(") + ").*?"
        end

        patterns << pattern
      end

      patterns
    end

    # NOTE: This is actually a glob-to-regex method
    def unglobify(glob)
      chars = glob.split("")

      chars = smoosh(chars)

      curlies = 0
      escaping = false
      string = chars.map do |char|
        if escaping
          escaping = false
          char
        else
          case char
            when "**"
              "([^/]+/)*"
            when '*'
              ".*"
            when "?"
              "."
            when "."
              "\."

            when "{"
              curlies += 1
              "("
            when "}"
              if curlies > 0
                curlies -= 1
                ")"
              else
                char
              end
            when ","
              if curlies > 0
                "|"
              else
                char
              end
            when "\\"
              escaping = true
              "\\"
            else
              char
          end
        end
      end

      '(\A|\/)' + string.join + '\Z'
    end

    def smoosh(chars)
      out = []

      until chars.empty?
        char = chars.shift

        if char == "*" && chars.first == "*"
          chars.shift
          chars.shift if chars.first == "/"
          out.push("**")
        else
          out.push(char)
        end
      end

      out
    end

    # Parse a file to find tasks
    def parsef!(file: "")
      types = @type ? [@type] : VALID_TASKS

      File.open(file, "r") do |f|
        line_number = 1
        while line = f.gets
          types.each do |type|
            result = line.match /#{Regexp.escape(type)}[\s,:-]+(\S.*)\Z/ rescue nil

            unless result.nil?
              task = {
                file: file,
                line_number: line_number,
                task: result.to_a.last
              }

              @tasks[type.to_sym] << task
            end
          end

          line_number += 1
        end
      end
    end
  end
end
