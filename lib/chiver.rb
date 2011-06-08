require "date"
require "rubygems"
require "bundler/setup"
Bundler.require

module Chiver
  class App < Sinatra::Base
    register SinatraMore::MarkupPlugin
    set :root,  Dir.pwd
    set :pages, File.join(root, "pages")
    set :haml,  :format => :html5
    set :sass,  :views => "#{root}/public/stylesheets"
    set :title, "Chiver"
    set :ext,   ".md"

    helpers do
      def convert(name)
        filename = File::basename(name) + settings.ext
        text = File.read(File.join(settings.pages, filename))
        text = Markdown.new(text, :fenced_code, :autolink, :generate_toc, :lax_htmlblock, :tables, :hard_wrap).to_html
        html = Nokogiri::HTML(text)
        before = html.css("code").to_s
        after = before.gsub("\n", "<br>")
        html.to_s.gsub(before, after)
      end
    end

    before do
      @title = settings.title
    end

    error { haml :error } unless development?

    get "/stylesheets/:name.css" do
      content_type "text/css", :charset => "utf-8"
      sass params[:name].to_sym
    end

    get "/javascripts/:js.css" do
      content_type "application/x-javascript", :charset => "utf-8"
      "#{settings.root}/public/js/#{params[:name]}"
    end

    get "/" do
      @entries = Dir::glob("#{settings.pages}/*#{settings.ext}")\
        .sort{|a, b| b<=>a }\
        .map{|file|
          y, m, d, name = File::basename(file).split("-")
          next unless [y, m, d, name].all?
          { :date => Date.new(y.to_i, m.to_i, d.to_i), :name => name.split(".").first }
        }
      haml :index
    end

    get /^.([^\.]+).*$/ do
      @text = convert(params[:captures][0])
      haml :page
    end
  end
end
