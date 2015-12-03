module API
  class CapturesController < API::BaseController

    before_filter -> { require_scope! :capture }

    def index
      @captures = current_user.captures.pending.order created_at: :asc
      respond_to { |format|
        format.org  { render body: @captures.map(&:to_org).join("\n\n") }
        format.json { render json: @captures }
      }
    end

    def show
      @capture = current_user.captures.find_by! key: params[:id]
      respond_to { |format|
        format.org  { render body: @capture.to_org }
        format.json { render json: @capture.to_json }
      }
    end

  end
end
