# frozen_string_literal: true

class CartItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |_e|
    redirect_to cart_path, alert: t('flash.cart_items.error.not_found')
  end

  def create
    # 現在のカートにすでに対象の商品が登録されていれば数量を増加させる。それ以外の場合は新規作成
    # find_or_initialize_byは存在していればそれをitemに格納、存在していなければ作成(new)してitemに格納してくれる
    item = current_cart.cart_items.find_or_initialize_by(product_id: cart_item_params[:product_id])
    # アイテムの数量を送られてきたquantity分増加、to_iは数値にするという意味
    item.quantity += cart_item_params[:quantity].to_i
    redirect_after_save(item, notice: t('flash.cart_items.create.notice'))
  end

  def update
    # 現在のカードの対象の商品を取得
    item = current_cart.cart_items.find(params[:id])
    # quantityを変える
    item.quantity = cart_item_params[:quantity].to_i
    redirect_after_save(item)
  end

  def destroy
    item = current_cart.cart_items.find(params[:id])
    item.destroy!
    redirect_to cart_path
  end

  private

  def cart_item_params
    # セキュリティ向上のため、他のパラメータを変更できないようにする
    params.require(:cart_item).permit(:product_id, :quantity)
  end

  def redirect_after_save(item, notice: nil)
    if item.save
      # 保存に成功したら画面は元の画面になる。失敗した時にはカート画面へ遷移
      redirect_to cart_path, notice: notice
    else
      redirect_to cart_path, alert: item.errors.full_messages.join(', ')
    end
  end
end
