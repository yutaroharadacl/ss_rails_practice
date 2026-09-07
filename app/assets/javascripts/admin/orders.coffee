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
