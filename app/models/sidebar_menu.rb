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
          name: '受注管理',
          path: '/admin/orders'
        }
      ]
    }
  ].freeze
end
