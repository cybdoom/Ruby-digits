require 'json'

class Task
  MESSAGES = {
    summary: %Q{
The program identifies 3 numbers: abc, def and ghi, the sum of which equals the user typed number. The
digits of the 3 identified numbers are all different (no digit appears twice).

Example:

  abc
  def
  ghi
  ---
  number
},
    prompt_number: %Q{
Type a number with 3 or 4 digits:
},
    prompt_print_all: %Q{
Show all solutions (y/n) ?
},
    validation_error: 'Wrong data was given. Please retry and pay attantion if the number is 3 or 4 digits and the flag for showing results is "y" or "n"'
  }

  def initialize
    @number, @print_all = Task.ask_user_for_input
    @number, @print_all = @number.to_i, @print_all == 'y'
    load_divisions
  end

  def solve
    @time = Time.now
    @solutions = []
    found = false
    @divisions.each do |_, divisions|
      divisions.each do |division|
        if is_sum?(division)
          @solutions << division
          found = true
          break unless @print_all
        end
      end
      break if found
    end
    @all_solutions = []
    if @print_all
      @solutions.each { |solution| solution[0].permutation {|permutation_1| solution[1].permutation {|permutation_2| solution[2].permutation {|permutation_3| @all_solutions << [permutation_1, permutation_2, permutation_3] } } } }
    else
      @all_solutions = @solutions.clone
    end
    @time = Time.now - @time
  end

  def print_results
    @all_solutions.each_with_index do |solution, index|
      puts %Q{
Solution ##{index}:
    #{get_number(solution, 0)}
    #{get_number(solution, 1)}
    #{get_number(solution, 2)}
    ---
    #{@number}

Time taken: #{@time}
}
    end
  end

  def is_sum? division
    sum = 0;
    3.times {|index| sum += get_number division, index }
    sum == @number
  end

  def get_number division, index
    100*division[0][index] + 10*division[1][index] + division[2][index]
  end

  def load_divisions
    File.open('divisions.json', 'r') {|file_stream| @divisions = JSON.load file_stream }
  end

  class << self

    def valid_data? given_number, print_all
      (100..9999).include?(given_number.to_s.to_i) && ['y', 'n'].include?(print_all)
    end

    def get_all_subsets absent_digit
      result = []
      digits = (0..9).to_a
      digits.delete absent_digit

      digits.combination(3) do |combination|
        digits_left = digits - combination
        digits_left.combination(3) { |sub_combination| result << [combination, sub_combination, digits_left - sub_combination] unless combination.include? 0 }
      end

      result
    end

    def generate_and_save_divisions
      result = {}
      (0..9).each {|digit| result[digit] = Task.get_all_subsets digit }
      File.open('divisions.json', 'w') {|file_stream| file_stream.puts JSON.dump result }
    end

    def ask_user_for_input
      puts Task::MESSAGES[:summary]

      loop do
        puts Task::MESSAGES[:prompt_number]
        given_number = $stdin.readline.strip
        puts Task::MESSAGES[:prompt_print_all]
        print_all = $stdin.readline.strip
        if Task.valid_data?(given_number, print_all)
          return [given_number, print_all]
        else
          puts Task::MESSAGES[:validation_error]
        end
      end
    end

  end
end

# Task.generate_and_save_divisions

task = Task.new
task.solve
task.print_results
