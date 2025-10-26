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
                             .order(created_at: :desc)
  end

  def translatable_resource_type
    BetterTogether::Community.name
  end
end
