require "find"
require "pathname"

module TaskList
  class Parser
    attr_reader :files, :tasks, :search_path, :github

    def initialize(arguments: [], options: {})
      self.search_path = options[:search_path]
      @github = options[:github] if options[:github]
      @plain = options[:plain] if options[:plain]
      @type = options[:type].upcase if options[:type]
      @files = fuzzy_find_files queries: arguments
      @tasks = {}
      VALID_TASKS.each { |t| @tasks[t.to_sym] = [] }
    end

    def search_path=(value)
      if value.nil? || value.empty?
        @search_path = "."
      else
        @search_path = value
      end
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

          if self.github? || self.plain?
            puts
          end

          tasks.each do |task|
            if self.github?
              if Pathname.new(self.search_path).absolute?
                reference = "#{task[:file].sub(/#{Regexp.escape(self.git_repo_root)}\//, "")}#L#{task[:line_number]}"
              else
                search_path_components = File.expand_path(self.search_path).split(File::SEPARATOR)
                search_path_components.pop
                parent = File.join(*search_path_components)
                file = task[:file].sub(/#{Regexp.escape(parent)}\//, "")
                reference = "#{file}#L#{task[:line_number]}"
              end

              puts "- #{task[:task]} &mdash; [#{reference}](#{reference})"
            else
              puts task[:task]

              if self.plain?
                puts "  line #{task[:line_number]} in #{task[:file]}"
              else
                puts "  \e[30m\e[1mline #{task[:line_number]} in #{task[:file]}\e[0m"
              end
            end
          end

          puts
        end
      end
    end

    def git_repo_root
      full_search_path = File.expand_path(self.search_path)
      root_path = full_search_path.dup
      repo_found = false

      begin
        if File.directory?(File.join(root_path, ".git"))
          repo_found = true
          break
        end

        directories = root_path.split(File::SEPARATOR)
        directories.pop
        root_path = File.join(*directories)
      end until repo_found

      unless repo_found
        # FIXME: Show an error message instead of raising an exception
        raise "No git repo found."
      end

      root_path
    end

    def github?
      !!@github
    end

    def plain?
      !!@plain
    end

    private

    def fuzzy_find_files(queries: [])
      patterns = regexify queries

      paths = []
      Find.find(File.expand_path(self.search_path)) do |path|
        paths << path unless FileTest.directory?(path)
      end

      paths.map! { |p| p.gsub(/\A\.\//, "") }

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
            result = line.match(/#{Regexp.escape(type)}[\s,:-]+(\S.*)\Z/) rescue nil

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
