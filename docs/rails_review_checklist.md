# Railsコードレビュー観点まとめ

現場のコードレビューで指摘された内容を、ファイル名や実装に依存しない形で一般化したチェックリスト。
別リポジトリで実装する際にも、同じ観点でセルフレビューする際の参考にする。

## 1. Controller — メッセージの扱い

- **flashメッセージはハードコードしない。** `config/locales/*.yml` にキー階層（例: `flash.<controller>.<action>.notice/error`）で定義し、コントローラからは `t('flash.xxx')` で呼び出す。
  - なぜ: 文言の一元管理、多言語対応、修正時の影響範囲を局所化するため。現場でもこの方式が一般的。

## 2. Controller — レコード取得（find系）

- `find` は対象が無いと `ActiveRecord::RecordNotFound` が**例外として発生する**。ユーザー操作起因（不正なID直打ちなど）で起こりうる箇所は、
  - `rescue ActiveRecord::RecordNotFound => e` で捕捉してエラーメッセージ＋リダイレクトにする、または
  - `find_by` を使い `nil` を許容して `xxx.blank?` などで後続分岐する

  のどちらかで、**システムエラーとしてユーザーに見せない**ようにする。
  - 特に一覧・詳細画面の `show` 系アクション、および `set_xxx` のような before_action の共通取得処理は要注意。

## 3. Controller — リダイレクト先

- `redirect_back` は研修・学習では問題ないが、現場では **`redirect_to` で遷移先を明示するケースがほぼ**。
  - 理由: `redirect_back` は `request.referer`（遷移元）に戻る。外部サイト経由でアクセスされた場合、エラー時に外部サイトへ戻ってしまい、エラーメッセージをユーザーに伝えられない、という事故が起こりうる。
  - 補足: 近年のブラウザはクロスオリジンでRefererを送らないことが多く、Rails 7以降は既定で外部ホストへのリダイレクトを拒否するため発生しにくくはなっているが、明示的な `redirect_to` の方が安全・意図が明確。

## 4. Controller — Strong Parameters

- `xxx_params` メソッドで受け取るパラメータを明示的に制限するのは**良い実装として継続すべき観点**。

## 5. Model — バリデーション

- DBのマイグレーション（型・NOT NULL制約など）に加えて、**モデル側にも `validates` でバリデーションを書く**のは良い観点として継続。
- ただし、バリデーションエラーメッセージにはデフォルトで**カラムの物理名がそのまま出る**（例: `product_id can't be blank`）。
  - `config/locales/*.yml` の `activerecord.attributes.<model>.<attribute>` に論理名（日本語名など）を定義しておくと、Railsが自動でそのキーを参照してメッセージ中の属性名を置き換えてくれる。
  - flashメッセージと違い、コントローラ側で `t(...)` を明示的に呼ぶ必要はない（Rails標準のI18n参照の仕組みに乗る）。

## 6. Migration — テーブル作成/削除

- `create_table` / `drop_table` を書く際は `change` ではなく **`up` / `down` に分ける**。
- それぞれ `data_source_exists?(:table_name)` で存在チェックしてから実行する。

```ruby
def up
  unless data_source_exists?(:carts)
    create_table :carts do |t|
      # ...
    end
  end
end

def down
  if data_source_exists?(:carts)
    drop_table :carts
  end
end
```

- なぜ: マイグレーションの再実行やロールバック（`rails db:rollback` やrevert対応）時に、テーブルの有無に関わらず安全に実行できるようにするため。

## 7. Controller — 検索機能

- 独自にクエリを組み立てる代わりに、**ransackのようなgemを使うと検索条件の実装がシンプルになる**ケースがある（要件次第）。イメージ:

```ruby
def index
  q_params = search_params
  @searched = q_params.values.any?(&:present?)

  @q = @store.products.includes(:sku).ransack(q_params)
  @products = @searched ? @q.result(distinct: true) : Model.none
end

private

def search_params
  params.fetch(:q, {}).permit(:name_cont, :sku_code_cont, :published_eq, :price_gteq, :price_lteq)
end
```

- あくまで一例であり、要件によって適不適があるので判断が必要。

## 8. Controller — CRUD操作の共通観点（show / create / update / destroy）

- **`show` 系**: `find` で見つからない場合、`RecordNotFound` をそのまま例外にせず、エラーハンドリングしてリダイレクト先とエラーメッセージを用意する（2と同じ観点）。
- **`create` / `update`**: `save` が `false` の場合、`render :new` / `render :edit` だけだと**なぜ失敗したかユーザーに伝わらない**。バリデーションエラーなど、意図的に定義したメッセージを画面に表示する（スタックトレースのような生の情報をそのまま出さない）。
- **`destroy`**: `destroy` の戻り値・結果を見ずに実行しっぱなしにしない。失敗した場合を検知できるようにする。
- **共通**: 成功時・失敗時の**両方**で、画面上にメッセージが表示されるようにする（無反応のまま画面遷移しない）。

## 9. その他・細かい規約

- `config/locales/*.yml` などのテキストファイルは**末尾に改行を入れる**。
- ファイル全体を通して、末尾改行漏れがないか確認する（エディタ設定で「保存時に自動追加」にしておくと防ぎやすい）。
