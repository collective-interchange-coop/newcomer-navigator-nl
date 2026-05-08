# frozen_string_literal: true

require 'digest'

module NewcomerNavigatorNl
  # Performance and safety overrides for BetterTogether navigation rendering.
  module NavigationItemsPerformanceHelper
    def better_together_nav_items
      visible_nav_items_for(better_together_nav_area)
    end

    def platform_host_nav_items
      visible_nav_items_for(platform_host_nav_area)
    end

    def platform_footer_nav_items
      visible_nav_items_for(platform_footer_nav_area)
    end

    def platform_header_nav_items
      visible_nav_items_for(platform_header_nav_area)
    end

    # rubocop:todo Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def navigation_item_visible_for?(navigation_item, platform: host_platform)
      return false unless navigation_item

      @navigation_item_visibility_cache ||= {}
      cache_key = [navigation_item.id, platform&.id, current_user&.id]
      return @navigation_item_visibility_cache[cache_key] if @navigation_item_visibility_cache.key?(cache_key)

      visible = navigation_item.visible_to?(current_user, platform:) ||
                (navigation_item.dropdown? &&
                  navigation_item.children.any? { |child| navigation_item_visible_for?(child, platform:) })

      @navigation_item_visibility_cache[cache_key] = visible
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def navigation_item_children_for(navigation_item, platform: host_platform)
      @navigation_item_children_cache ||= {}
      cache_key = [navigation_item.id, platform&.id, current_user&.id]
      return @navigation_item_children_cache[cache_key] if @navigation_item_children_cache.key?(cache_key)

      visible_children = navigation_item.children.select { |child| navigation_item_visible_for?(child, platform:) }
      @navigation_item_children_cache[cache_key] = visible_children
    end

    def cache_key_for_nav_area(nav)
      return super unless nav

      context_key = nav_visibility_context_key
      return super if context_key.blank?

      [
        'nav_area_items',
        nav.cache_key_with_version,
        context_key
      ]
    end

    private

    def visible_nav_items_for(nav_area)
      return [] unless nav_area

      @visible_navigation_items_cache ||= {}
      cache_key = [nav_area.id, nav_area.cache_key_with_version, nav_visibility_context_key]
      return @visible_navigation_items_cache[cache_key] if @visible_navigation_items_cache.key?(cache_key)

      nav_items = Mobility.with_locale(current_locale) { nav_area.top_level_nav_items_includes_children.to_a }
      @visible_navigation_items_cache[cache_key] =
        nav_items.select { |item| navigation_item_visible_for?(item, platform: host_platform) }
    end

    # rubocop:todo Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def nav_visibility_context_key
      context_parts = [
        "locale:#{current_locale}",
        "platform:#{host_platform&.cache_key_with_version || 'none'}",
        "auth:#{current_user ? 'user' : 'guest'}",
        "user:#{current_user&.cache_key_with_version || 'none'}",
        "permissions:#{nav_permission_cache_stamp}",
        "path:#{request&.path.to_s.hash}"
      ]

      return nil if context_parts.any?(&:blank?)

      Digest::SHA256.hexdigest(context_parts.join('|'))
    rescue StandardError
      nil
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    def nav_permission_cache_stamp
      return 'guest' unless current_user

      segments = [current_user.cache_key_with_version]
      segments.concat(membership_cache_segments)
      segments.concat(role_cache_segments)

      Digest::SHA256.hexdigest(segments.compact.join('|'))
    end

    # rubocop:todo Metrics/AbcSize
    def membership_cache_segments
      return [] unless current_user.class.respond_to?(:joinable_membership_classes)

      current_user.class.joinable_membership_classes.filter_map do |membership_class_name|
        membership_class = membership_class_name.to_s.safe_constantize
        next unless membership_class&.column_names&.include?('member_id')

        scope = membership_class.where(member_id: current_user.id)
        max_updated_at = scope.maximum(:updated_at).to_i
        "#{membership_class_name}:#{scope.count}:#{max_updated_at}"
      end
    end
    # rubocop:enable Metrics/AbcSize

    def role_cache_segments
      return [] unless current_user.respond_to?(:roles)

      roles_scope = current_user.roles
      max_updated_at = roles_scope.maximum(:updated_at).to_i
      ["roles:#{roles_scope.count}:#{max_updated_at}"]
    rescue StandardError
      []
    end
  end
end
