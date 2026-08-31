# frozen_string_literal: true

class CartItemsController < ApplicationController
  def create
    # 現在のカートにすでに対象の商品が登録されていれば数量を増加させる。それ以外の場合は新規作成
    item = current_cart.cart_items.find_or_initialize_by(product_id: cart_item_params[:product_id])
    # アイテムの数量を送られてきたquantity分増加、to_iは数値にするという意味
    item.quantity += cart_item_params[:quantity].to_i

    if item.save
      # 保存に成功したら画面は元の画面になる。失敗した時にはカート画面へ遷移
      redirect_back fallback_location: cart_path, notice: 'カートに追加しました'
    else
      redirect_back fallback_location: cart_path, alert: item.errors.full_messages.join(', ')
    end
  end

  def update
    # 現在のカードの対象の商品を取得
    item = current_cart.cart_items.find(params[:id])
    # quantityを変える
    item.quantity = cart_item_params[:quantity].to_i
    if item.save
      redirect_back fallback_location: cart_path
    else
      redirect_back fallback_location: cart_path, alert: item.errors.full_messages.join(', ')
    end
  end

  def destroy
    item = current_cart.cart_items.find(params[:id])
    item.destroy!
    redirect_back fallback_location: cart_path
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity, :unit_price)
  end
end
