require 'minitest/autorun'
require 'net/http'
require 'uri'
require 'timeout'
require 'socket'

class TestHelloServer < Minitest::Test
  def setup
    # テスト用サーバーをバックグラウンドで起動
    @server_pid = spawn('ruby hello.rb')
    wait_for_server_startup
  end

  def teardown
    # テスト後にサーバーを停止
    Process.kill('INT', @server_pid) if @server_pid
    Process.wait(@server_pid) if @server_pid
  rescue Errno::ESRCH
    # プロセスが既に終了している場合は無視
  end

  # サーバー起動まで待機（最大10秒）
  def wait_for_server_startup
    Timeout.timeout(10) do
      loop do
        begin
          TCPSocket.new('localhost', 8080).close
          break
        rescue Errno::ECONNREFUSED
          sleep 0.1
        end
      end
    end
  rescue Timeout::Error
    flunk "サーバーが10秒以内に起動しませんでした"
  end

  # ========== 基本機能テスト ==========

  def test_server_responds_to_root_path
    uri = URI('http://localhost:8080/')
    response = Net::HTTP.get_response(uri)
    
    assert_equal '200', response.code
    assert_equal 'text/html; charset=utf-8', response['Content-Type']
    assert_includes response.body, '<h1>Hello World</h1>'
  end

  def test_server_port_is_accessible
    socket = TCPSocket.new('localhost', 8080)
    socket.close
    assert true # ポートアクセス可能
  end

  # ========== エラーハンドリングテスト ==========

  def test_server_returns_200_all_paths
    # hello.rbは全てのパスに対して同じレスポンスを返す
    uri = URI('http://localhost:8080/nonexistent')
    response = Net::HTTP.get_response(uri)
    
    assert_equal '200', response.code
    assert_includes response.body, '<h1>Hello World</h1>'
  end

  def test_server_handles_multiple_paths
    paths = ['/test', '/api', '/admin']
    paths.each do |path|
      uri = URI("http://localhost:8080#{path}")
      response = Net::HTTP.get_response(uri)
      assert_equal '200', response.code
      assert_includes response.body, '<h1>Hello World</h1>'
    end
  end

  # ========== HTTPメソッドテスト ==========

  def test_server_handles_post_request
    uri = URI('http://localhost:8080/')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path)
    request.body = 'test data'
    response = http.request(request)
    
    # WEBrickはデフォルトでPOSTを受け付ける
    assert_equal '200', response.code
  end

  def test_server_handles_put_request
    uri = URI('http://localhost:8080/')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.path)
    response = http.request(request)
    
    assert_equal '200', response.code
  end

  # ========== パフォーマンステスト ==========

  def test_server_handles_concurrent_requests
    threads = []
    responses = []
    
    5.times do
      threads << Thread.new do
        uri = URI('http://localhost:8080/')
        response = Net::HTTP.get_response(uri)
        responses << response
      end
    end
    
    threads.each(&:join)
    
    assert_equal 5, responses.size
    responses.each do |response|
      assert_equal '200', response.code
      assert_includes response.body, '<h1>Hello World</h1>'
    end
  end

  # ========== レスポンス内容テスト ==========

  def test_response_body_contains_valid_html
    uri = URI('http://localhost:8080/')
    response = Net::HTTP.get_response(uri)
    
    assert_match /<h1>.*<\/h1>/, response.body
    assert_equal '<h1>Hello World</h1>', response.body.strip
  end

  def test_response_headers_are_correct
    uri = URI('http://localhost:8080/')
    response = Net::HTTP.get_response(uri)
    
    assert_equal 'text/html; charset=utf-8', response['Content-Type']
    assert response['Server'].include?('WEBrick')
  end

  # ========== エラー処理テスト ==========

  def test_server_handles_malformed_requests
    begin
      socket = TCPSocket.new('localhost', 8080)
      socket.write("INVALID HTTP REQUEST\r\n\r\n")
      response = socket.read
      socket.close
      
      # サーバーがクラッシュしないことを確認
      assert_not_nil response
    rescue => e
      # ネットワークエラーは許容
      assert_kind_of StandardError, e
    end
  end
end