require "date"
require "rubygems"
require "sinatra/base"
require "sinatra_more/markup_plugin"
require "i18n"
require "haml"
require "sass"
require "redcarpet"
require "nokogiri"

class Chiver < Sinatra::Base
  register SinatraMore::MarkupPlugin
  set :root,  Dir.pwd
  set :pages, File.join(root, "pages")
  set :haml,  :format => :html5
  set :sass,  :views => "#{root}/public/stylesheets"
  set :title, root.split("/").last
  set :ext,   ".md"

  helpers do
    def convert(name)
      filename = File::basename(name) + settings.ext
      text = File.read(File.join(settings.pages, filename))
      text = Markdown.new(text, :fenced_code, :autolink, :generate_toc, :lax_htmlblock, :tables, :hard_wrap)
      html = Nokogiri::HTML(text.to_html)
      html.css("code").inject(html.to_s){|r, c| r.gsub(c.to_s, c.to_s.gsub("\n", "<br>")) }
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

  get "/" do
    @entries = Dir::glob("#{settings.pages}/*#{settings.ext}")\
      .sort{|a, b| b<=>a }\
      .map{|file|
        y, m, d, name = File::basename(file).split("-", 4)
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
