# Ruby WEBrick Server

シンプルなRuby WEBrickサーバーの実装とテストスイート

## ファイル構成

- `hello.rb` - WEBrickを使用したHTTPサーバー
- `test_hello.rb` - 包括的なテストスイート

## 使用方法

### サーバー起動
```bash
ruby hello.rb
```

サーバーは http://localhost:8080 で起動します。

### サーバー停止
`Ctrl+C` でサーバーを停止できます。

### テスト実行
```bash
ruby test_hello.rb
```

## 機能

- ポート8080でHTTPサーバーを起動
- 全てのパスに対して "Hello World" を返す
- 適切なContent-Typeヘッダー設定
- 優雅なシャットダウン処理

## テスト内容

- 基本的なHTTP機能テスト
- 複数HTTPメソッド対応（GET、POST、PUT）
- 並行リクエスト処理テスト
- レスポンス検証テスト
- エラーハンドリングテスト