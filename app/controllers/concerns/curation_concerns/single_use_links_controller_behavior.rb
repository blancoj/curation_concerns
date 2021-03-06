module CurationConcerns
  module SingleUseLinksControllerBehavior
    extend ActiveSupport::Concern
    included do
      before_action :authenticate_user!
      before_action :authorize_user!
      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
        if current_user && current_user.persisted?
          redirect_to main_app.root_url, alert: "You do not have sufficient privileges to create links to this document"
        else
          session["user_return_to"] = request.url
          redirect_to new_user_session_url, alert: exception.message
        end
      end
    end

    def create_download
      @su = SingleUseLink.create itemId: params[:id], path: main_app.download_path(id: asset)
      render text: curation_concerns.download_single_use_link_url(@su.downloadKey)
    end

    def create_show
      @su = SingleUseLink.create itemId: params[:id], path: polymorphic_path([main_app, asset])
      render text: curation_concerns.show_single_use_link_url(@su.downloadKey)
    end

    protected

      def authorize_user!
        authorize! :edit, asset
      end

      def asset
        @asset ||= ActiveFedora::Base.load_instance_from_solr(params[:id])
      end
  end
end
