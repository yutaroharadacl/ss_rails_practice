# frozen_string_literal: true

module ApplicationHelper
  def current_major_menu_item
    SidebarMenu::MENU_ITEMS.find do |item|
      item[:children].present? && item[:children].any? { |child| path_matches?(child[:path]) }
    end
  end

  private

  def path_matches?(path)
    request.path == path || (path != '/' && request.path.start_with?("#{path}/"))
  end
end
