# frozen_string_literal: true

module ApplicationHelper
  def current_major_menu_item
    SidebarMenu::MENU_ITEMS.find do |item|
      item[:children].present? && item[:children].any? { |child| current_page?(child[:path]) }
    end
  end
end
