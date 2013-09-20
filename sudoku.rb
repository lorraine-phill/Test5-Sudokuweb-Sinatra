require 'sinatra'
require 'new_relic'
require_relative './lib/sudoku'
require_relative './lib/cell'
require 'sinatra/partial' 
set :partial_template_engine, :erb
require 'rack-flash'
use Rack::Flash

enable :sessions

helpers do
      def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
        must_be_guessed = puzzle_value.to_i == 0
        # I needed to change this 0 to "0" otherwise all the cells show up as value provided
        tried_to_guess = current_solution_value.to_i != 0
        guessed_incorrectly = current_solution_value != solution_value
        if solution_to_check && 
            must_be_guessed && 
            tried_to_guess && 
            guessed_incorrectly
          'incorrect'
        elsif !must_be_guessed
          'value-provided'
        elsif tried_to_guess
           'correct'
        end
      end
    end

  helpers do
      def cell_value(value)
        value.to_i == 0 ? '' : value
      end
    end

    def random_sudoku
	    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
        # it's obvious there may be no clashes as all numbers are unique
        seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
        sudoku = Sudoku.new(seed.join) # then we solve this (really hard!) sudoku
        sudoku.solve! # and give the output to the view as an array of chars
        sudoku.to_s.chars
    end

    def puzzle(sudoku)
        # a = (0..80).to_a.sample(14)
        sudoku = sudoku.dup
        [5,8,11,12,16,19,21,22,28,35,39,44,48,52,58,61,62,66,73,78].each do |index|
        sudoku[index] = '' 
        end
        sudoku
    end

    def generate_new_puzzle_if_necessary
      return if session[:current_solution]
      sudoku = random_sudoku
      session[:solution] = sudoku
      session[:puzzle] = puzzle(sudoku)
      session[:current_solution] = session[:puzzle]    
    end

    def prepare_to_check_solution
      @check_solution = session[:check_solution]
      session[:check_solution] = nil
    end

    def prepare_to_check_solution
      @check_solution = session[:check_solution]
      if @check_solution
        flash[:notice] = "Incorrect values are highlighted in yellow. Correct values are highlighted in green."
      end
      session[:check_solution] = nil
    end

    get '/reset' do
      session[:solution] = nil
      session[:current_solution] = nil
      session[:last_visit] = nil
      redirect to('/')
    end

    get '/' do
      prepare_to_check_solution
      generate_new_puzzle_if_necessary
      @current_solution = session[:current_solution] || session[:puzzle]
      @solution = session[:solution]
      @puzzle = session[:puzzle]
      # raise "test"
      erb :index
    end

    post '/' do
      boxes = params["cell"].each_slice(9).to_a
      cells = (0..8).to_a.inject([]) {|memo, i|
        memo += boxes[i/3*3, 3].map{|box| box[i%3*3, 3] }.flatten
      }
      session[:current_solution] = cells
      session[:check_solution] = true
      redirect to("/")
    end

    # post '/' do
    #   cells = params["cell"]
    #   session[:current_solution] = cells.map{|value| value.to_i }.join
    #   session[:check_solution] = true
    #   redirect to("/")
    # end

    get '/solution' do
        @current_solution = session[:solution]
        @solution = session[:solution]
        @puzzle = session[:puzzle]
        erb :index
    end

