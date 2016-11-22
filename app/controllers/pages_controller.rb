
class PagesController < ApplicationController
  def game
    @start_time = Time.now
    @grid = generate_grid(9)
  end

  def score
    end_time = Time.now.to_f
    grid = params[:grid].split("")
    start_time = params[:start_time].to_f
    attempt = params[:attempt]
    @result = run_game(attempt, grid, start_time, end_time)
  end
  
  private
  
  def generate_grid(grid_size)
    letters = ("A".."Z").to_a
    grid = []
    grid_size.times do
      grid << letters.sample
    end
    return grid
  end
  
  def in_grid?(grid, attempt_array)
    attempt_array.all? do |letter|
      if grid.include? letter
        grid.each_with_index do |item, index|
          grid.delete_at(index) if item == letter
        end
        true
      end
    end
  end
  
  def compute_result(result, grid, attempt, translations)
    if translations.key?("term0") && in_grid?(grid, attempt.upcase.split(""))
      result[:translation] = translations["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      result[:score] = attempt.size / result[:time] * 10
      result[:message] = "Well done !"
    elsif !in_grid?(grid, attempt.upcase.split(""))
      result[:message] = "not in the grid X("
    else
      result[:message] = "not an english word X("
    end
    result
  end
  
  def run_game(attempt, grid, start_time, end_time)
    url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
    translations_serialized = open(url).read
    translations = JSON.parse(translations_serialized)
    result = { time: end_time - start_time, score: 0 }
    compute_result(result, grid, attempt, translations)
  end
end
