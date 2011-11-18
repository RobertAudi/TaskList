require_relative "spec_helper"

describe "Parser" do
  it "must work" do
    lambda do
      TaskList::Parser
    end.must_be_silent
  end

  describe "arguments" do
    it "must require at least one argument" do
      lambda do
        TaskList::Parser.new
      end.must_raise ArgumentError
    end
  end
end
