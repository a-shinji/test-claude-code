# WEBrickライブラリを読み込み（RubyのHTTPサーバーライブラリ）
require 'webrick'

# ポート8080でHTTPサーバーインスタンスを作成
server = WEBrick::HTTPServer.new(Port: 8080)

# ルートパス「/」へのリクエストに対するハンドラーを設定
server.mount_proc '/' do |req, res|
  # レスポンスのContent-Typeヘッダーを設定（HTML、UTF-8エンコード）
  res['Content-Type'] = 'text/html; charset=utf-8'
  # レスポンスボディにHTMLコンテンツを設定
  res.body = '<h1>Hello World</h1>'
end

# Ctrl+C（SIGINT）シグナルをキャッチしてサーバーを優雅に停止
trap 'INT' do
  server.shutdown
end

# サーバー起動メッセージを表示
puts "サーバーを起動しました: http://localhost:8080"
# サーバーを起動（ブロッキング処理）
server.start