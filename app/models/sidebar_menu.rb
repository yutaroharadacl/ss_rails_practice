# frozen_string_literal: true

class SidebarMenu
  MENU_ITEMS = [
    {
      name: 'Home',
      children: [
        {
          name: 'Home',
          path: '/'
        }
      ]
    },
    {#商品一覧画面を２つ用意しておりますが、
     #１つはユーザー側の商品一覧画面、もう１つは店舗側の商品管理画面です。
     #アカウントの種類によって表示を切り替えるために、childrenを使用しています。
  name: 'Products',
  children: [
    {
      name: '商品一覧',
      path: '/products'
    },
    {
      name: '店舗の商品管理',
      path: '/admin/stores/1/products'
    }
  ]
},
    {
      name: 'Cart',
      children: [
        {
          name: 'Cart',
          path: '/cart'
        }
      ]
    }
  ].freeze
end
