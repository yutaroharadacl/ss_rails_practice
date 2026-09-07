# frozen_string_literal: true

# 消費税率。OrderとCartでそれぞれ計算の仕方（小計/税/合計を別々に出す vs 合計だけ出す）
# が異なるため計算式自体は共通化しないが、税率の値だけはここに一本化する。
module TaxRate
  PERCENT = 10
end
