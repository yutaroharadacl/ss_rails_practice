# 受注詳細画面のタブ（基本情報 / 受注商品管理）の状態をURLのハッシュと連動させる。
# - ページ表示時：URLに#tab-itemsのようなハッシュがあれば、そのタブを開いた状態にする
#   （サーバーからのリダイレクト先URLにハッシュが付いている場合もこれで復元される）
# - タブ切り替え時：クリックしたタブのidをURLのハッシュに反映する（ブックマーク・再読み込みでも残るように）
# turbolinks:load を使うのは、Turbolinksがページ遷移してもDOMContentLoadedが発火しないため。
$(document).on 'turbolinks:load', ->
  hash = window.location.hash
  if hash
    $(".nav-tabs a[href=\"#{hash}\"]").tab('show')

  $('.nav-tabs a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    window.location.hash = $(e.target).attr('href')

# 商品追加モーダルを開いたら、検索フォームを送信して候補商品を読み込む。
# 受注詳細を開くたびに全商品を読むのを避けるため、一覧の取得はモーダルを開いた時だけ行う。
# documentへの委譲なので、Turbolinksでページが差し替わっても登録し直す必要がない。
$(document).on 'shown.bs.modal', '#add-product-modal', ->
  $('#product-search-form').submit()

# 商品追加後のリダイレクト（open_modal=1付き）ではモーダルを開き直す。
# 検索条件はURLのqパラメータから復元され、上のshown.bs.modalで再検索される。
$(document).on 'turbolinks:load', ->
  if window.location.search.indexOf('open_modal=1') >= 0
    $('#add-product-modal').modal('show')
    # 一度きりのフラグなので、開いたらURLから消す（リロードや戻るで再度開かないように）
    history.replaceState({}, '', window.location.pathname + window.location.hash)
