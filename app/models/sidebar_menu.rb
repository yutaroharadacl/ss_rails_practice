# frozen_string_literal: true

class SidebarMenu
  def self.menu_items
    demo_store = Store.find_by(code: 'DEMO')
    products_admin_path =
      if demo_store
        "/admin/stores/#{demo_store.id}/products"
      else
        '/products'
      end

    [
      {
        name: 'Home',
        children: [
          {
            name: 'Home',
            path: '/products'
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
      },
      {
        name: '管理',
        children: [
          {
            name: '商品管理',
            path: products_admin_path
          },
          {
            name: '受注管理',
            path: '/admin/orders'
          }
        ]
      }
    ].freeze
  end
end
