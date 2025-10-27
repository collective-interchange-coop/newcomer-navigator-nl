# frozen_string_literal: true

class PartnersController < BetterTogether::CommunitiesController # rubocop:todo Style/Documentation
  def index
    authorize resource_class
    @partners = policy_scope(resource_collection)

    # Add cache headers for better browser/CDN caching
    return unless Rails.env.production?

    expires_in 15.minutes, public: true
  end

  def new
    @partner = resource_class.new
    authorize_partner
  end

  def create # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
    @partner = resource_class.new(partner_params)
    authorize_partner

    respond_to do |format|
      if @partner.save
        flash[:notice] = t('partner.created')
        format.html { redirect_to edit_partner_path(@partner), notice: t('partner.created') }
        format.turbo_stream do
          redirect_to edit_partner_path(@partner), only_path: true
        end
      else
        flash.now[:alert] = t('partner.create_failed')
        format.html { render :new, status: :unprocessable_content }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('form_errors', partial: 'layouts/better_together/errors',
                                               locals: { object: @partner }),
            turbo_stream.update('partner_form', partial: 'partners/form',
                                                locals: { partner: @partner })
          ]
        end
      end
    end
  end

  def update # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
    authorize_partner

    respond_to do |format|
      if @partner.update(partner_params)
        flash[:notice] = t('partner.updated')
        format.html { redirect_to edit_partner_path(@partner), notice: t('partner.updated') }
        format.turbo_stream do
          redirect_to edit_partner_path(@partner), only_path: true
        end
      else
        flash.now[:alert] = t('partner.update_failed')
        format.html { render :new, status: :unprocessable_content }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('form_errors', partial: 'layouts/better_together/errors',
                                               locals: { object: @partner }),
            turbo_stream.update('partner_form', partial: 'partners/form',
                                                locals: { partner: @partner })
          ]
        end
      end
    end
  end

  # AJAX endpoint for loading available people for member addition with search support
  def available_people
    set_model_instance
    authorize @partner, :manage_members?

    # Start with people not already members
    available_people_scope = ::BetterTogether::Person
                             .where.not(id: @partner.person_community_memberships.select(:member_id))
                             .includes(:string_translations)

    # Apply search filter if search parameter is present (SlimSelect sends 'search' parameter)
    search_term = params[:search].to_s.strip

    if search_term.present?
      available_people_scope = available_people_scope.joins(:string_translations)
                                                     .where(
                                                       'mobility_string_translations.key = ? AND mobility_string_translations.value ILIKE ?',
                                                       'name', "%#{search_term}%"
                                                     ).distinct
    end
    # If no search term, we'll return first 20 results for initial display

    # Apply policy scoping to ensure users only see people they're authorized to view
    @available_people = policy_scope(available_people_scope.order(:created_at))

    # Format response for SlimSelect (same format as person_blocks_controller#search)
    people_data = @available_people.limit(20).map do |person|
      {
        text: person.name,
        value: person.id.to_s
      }
    end

    respond_to do |format|
      format.json do
        render json: people_data
      end
    end
  end

  protected

  # Adds a policy check for the community
  def authorize_community
    authorize @partner
  end

  alias authorize_partner authorize_community

  def partner_params
    community_params
  end

  def set_model_instance
    @partner = set_resource_instance
  end

  def resource_class
    Partner
  end

  def resource_collection
    # Optimize partner loading with comprehensive eager loading to prevent N+1 queries
    @resource_collection ||= super
                             .includes(
                               # Preload string translations efficiently (avoid complex outer joins)
                               :string_translations,
                               # Preload Active Storage attachments and blobs to prevent N+1
                               logo_attachment: :blob,
                               profile_image_attachment: :blob
                             )
                             .i18n.order(name: :asc, created_at: :desc)
  end

  def show
    set_model_instance
    authorize @partner

    # Comprehensive preloading for show view performance
    @partner = resource_class
               .includes(
                 # Preload all translations (string and text)
                 :string_translations, :text_translations,
                 # Preload Active Storage attachments and blobs to prevent N+1
                 logo_attachment: :blob,
                 profile_image_attachment: :blob,
                 cover_image_attachment: :blob,
                 # Preload contacts and their associations
                 contacts: %i[
                   phone_numbers email_addresses addresses website_links
                   social_media_accounts
                 ],
                 # Preload geography/map data
                 map: [:spaces],
                 # Preload building connections and buildings
                 building_connections: [
                   building: [
                     :string_translations, :text_translations,
                     { primary_address: [] }
                   ]
                 ],
                 # Preload memberships with member details
                 person_community_memberships: [
                   member: [
                     :string_translations,
                     { profile_image_attachment: :blob }
                   ],
                   role: %i[string_translations text_translations]
                 ],
                 # Preload hosted events
                 hosted_events: [:string_translations]
               )
               .find(params[:id])

    # Add cache headers for better browser/CDN caching
    return unless Rails.env.production?

    expires_in 15.minutes, public: true
  end

  def translatable_resource_type
    BetterTogether::Community.name
  end
end
