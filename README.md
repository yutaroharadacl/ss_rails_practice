# ss_rails_practice

## 技術スタック

- Ruby 2.7.8 / Rails 6.0.6.1
- アプリサーバ: Puma
- DB: MySQL 5.7（開発）/ TiDB（一部環境、MySQLプロトコル互換）
- フロント: Haml, SCSS + Bootstrap 3, CoffeeScript + jQuery + Backbone.js, Sprockets, Turbolinks, Liquid
- API: REST API（`/api/v1`, `/api/v2`）
- 決済: ダミー
- テスト / Lint / セキュリティ: RSpec / RuboCop / Brakeman

## セットアップ

### 1. Rubyバージョンの切り替え

このディレクトリでは `.ruby-version`（2.7.8）に従い、rbenv経由で自動的に該当のRubyが使われます。

```bash
rbenv exec ruby -v
```

### 2. gemのインストール

Bundler 2.4.22を使用します（`Gemfile.lock`の`BUNDLED WITH`と一致させること）。

```bash
bundle install
```

> `concurrent-ruby`は`1.3.4`にバージョン固定しています。1.3.5以降には
> `uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger` を
> 引き起こす既知の非互換があるため、`bundle update`時にこの固定を外さないこと。

### 3. Docker（MySQL 5.7 / TiDB / Redis）の起動

`mysql:5.7`はArm64ネイティブイメージが無いため、`docker-compose.yml`で
`platform: linux/amd64`を指定してエミュレーション実行しています。

```bash
docker-compose up -d
```

起動確認:

```bash
docker-compose ps
```

停止する場合:

```bash
docker-compose down
```

データも含めて完全に削除する場合:

```bash
docker-compose down -v
```

### 4. データベースの作成・マイグレーション

MySQL 5.7（development / test）:

```bash
bin/rails db:create
bin/rails db:migrate
```

## アプリケーションの起動

```bash
bin/rails server
```

`http://localhost:3000` で確認できます。

ポート3000が使用中の場合:

```bash
bin/rails server -p 3001
```

## テスト（RSpec）

```bash
bundle exec rspec
```

特定のディレクトリ・ファイルのみ実行する場合:

```bash
bundle exec rspec spec/requests
bundle exec rspec spec/services/payments/gateway_factory_spec.rb
```

## コード品質チェック（RuboCop）

```bash
bundle exec rubocop
```

自動修正可能な指摘を一括修正する場合:

```bash
bundle exec rubocop -A
```

## セキュリティスキャン（Brakeman）

```bash
bundle exec brakeman
```

レポートをファイル出力する場合（ターミナルのページャで止まる場合はこちらを使う）:

```bash
bundle exec brakeman -o brakeman_report.txt
cat brakeman_report.txt
```

> Ruby 2.7 / Rails 6.0 はEOLのため、`Unmaintained Dependency`の警告が
> 常に2件表示されます。これは意図した構成による既知の警告であり、
> 対応不要です。

## REST API(例)

```bash
curl http://localhost:3000/api/v1/health
curl http://localhost:3000/api/v2/health
```
