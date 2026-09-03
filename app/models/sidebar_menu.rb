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
    }
  ].freeze
end
