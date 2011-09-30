require "date"
require "yaml"
require "bundler/setup"
Bundler.require

class Chiver < Sinatra::Base
  register SinatraMore::MarkupPlugin
  set :sitename,  "Yuno"
  set :root,      Dir.pwd
  set :pages,     File.join(root, "pages")
  set :haml,      :format => :html5
  set :sass,      :views => File.join(root, "public", "stylesheets")

  helpers do
    # 入力: Markdown形式のテキストファイルのパス
    #   "/a/b/c.md"
    # 出力: 変換後のHTMLコードの文字列
    #   "<h1>title of c.md</h1>"
    def convert(path)
      str  = File.read(path)
      str  = Markdown.new(str, :fenced_code, :autolink, :generate_toc, :lax_htmlblock, :tables, :hard_wrap)
      html = Nokogiri::HTML(str.to_html)
      html.css("code").inject(html.to_s){|r, c| r.gsub(c.to_s, c.to_s.gsub("\n", "<br>")) }
    end

    # 入力: URLのドメインより後ろの部分
    #   "/a/b/c.md"
    # 出力: URLを構成する要素の配列
    #   [{:name => "a",    :path => "/a"},
    #    {:name => "b",    :path => "/a/b"},
    #    {:name => "c.md", :path => "/a/b/c.md"}]
    def ancestors(path)
      result = []
      result << {
        :name => "top",
        :path => "/",
      } if path != "/"

      path.split("/").reject{|str| str == "" }.inject([]) do |genealogy, basename|
        genealogy << basename
        result << {
          :name => basename,
          :path => "/" + genealogy.join("/"),
        }
        genealogy
      end
      result
    end

    # 入力: URLのドメインより後ろの部分
    #   "/a/b"
    # 出力: ディレクトリ以下に含まれる要素の配列
    #   [{:name => "b",    :path => "/a/b"},
    #    {:name => "c.md", :path => "/a/b/c"}]
    def children(path)
      dirpath = settings.pages + path
      Dir::entries(dirpath).reject{|basename| basename =~ /^\./ }.sort.reverse.map do |basename|
        {
          :name         => basename.split(".")[0],
          :path         => File.join(path, basename),
          :is_directory => FileTest.directory?(File.join(settings.pages, path, basename)),
        }
      end
    end
  end

  # favicon返したいけど、用意するの面倒なので何もしない
  get "/favicon.ico" do
  end

  # stylesheet返す
  get "/stylesheets/:name.css" do
    content_type "text/css", :charset => "utf-8"
    sass params[:name].to_sym
  end

  # パスの指す内容(target)が...
  # 1.存在しない場合
  #   - トップページにリダイレクトする
  # 2.ディレクトリの場合
  #   - 内包するパスのリストを表示する
  #   - 但し先頭がピリオドのものは無視する
  #   - ビューにlist.hamlを利用する
  # 3.ファイルの場合
  #   - ファイルの中身をMarkdown形式でHTMLに変換して表示する
  #   - ビューにpage.hamlを利用する
  get "*" do
    url = params[:splat][0]
    target = File.join(settings.pages + url)

    redirect "/" unless File.exist?(target)

    @ancestors = ancestors(url)
    if FileTest.directory?(target)
      @children = children(url)
      haml :list
    else
      @body = convert(target)
      haml :page
    end
  end
end

run Chiver
