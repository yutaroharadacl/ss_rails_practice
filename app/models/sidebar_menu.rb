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
      name: '注文',
      children: [
        {
          name: '注文',
          path: '/orders'
        }
      ]
    }
  ].freeze
end
