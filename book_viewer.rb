require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def format_paragraphs(text)
    text = text.join.split("\n\n")
    text.map!.with_index {|paragraph, idx| "<p id='par#{idx}'> #{paragraph} </p>"}
  end

  def highlight_match(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

def each_chapter
  @toc.each_with_index do |chapter_title, idx|
    chapter_number = idx + 1
    text = File.read("data/chp#{chapter_number}.txt")
    yield(chapter_number, chapter_title, text)
  end
end

def chapters_match(query)
  result = []
  return result if !query || query.empty?
 
  each_chapter do |number, title, text|
    paragraphs = {}
    text.split("\n\n").each_with_index do |par, idx|
      paragraphs[idx] = par if par.include?(query)
    end
    result << {chapter_number: number, chapter_title: title, paragraphs: paragraphs} if paragraphs.any?
  end

  result
end

before do
  @toc = File.readlines "data/toc.txt"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapter/:number" do
  @chap_number = params[:number]

  redirect "/" unless (1..@toc.size).map(&:to_s).include?(@chap_number)
  @title = "Chapter #{@chap_number}:  #{@toc[@chap_number.to_i - 1]}"
  @chapter = File.readlines "data/chp#{@chap_number}.txt"
  @chapter = format_paragraphs(@chapter)
  erb :chapter
end

get "/search" do
  @results = chapters_match(params[:query])
  erb :search
end

not_found do
  redirect "/"
end