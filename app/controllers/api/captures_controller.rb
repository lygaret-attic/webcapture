module API
  class CapturesController < API::BaseController

    before_filter -> { require_scope! :capture }

    def index
      @captures = current_user.captures.pending.order created_at: :asc
      respond_to { |format|
        format.org  { render body: @captures.pluck(:content).join("\n\n") }
        format.json { render json: @captures }
      }
    end

    def show
      @capture = current_user.captures.find_by! key: params[:id]
      respond_to { |format|
        format.org  { render body: @capture.content }
        format.json { render json: @capture.to_json }
      }
    end

    def create
      create_params = params.require(:capture).permit(:content)
      create_params.merge! status: :pending

      @capture = current_user.captures.create! create_params
      respond_to { |format|
        format.org  { render status: 201, body: @capture.content }
        format.json { render status: 201, json: @capture.to_json }
      }
    end

    def update
      update_params = params.require(:capture).permit(:content, :status)

      @capture = current_user.captures.find_by! key params[:key]
      @capture.update! update_params

      respond_to { |format|
        format.org  { render status: 200, body: @capture.content }
        format.json { render status: 200, json: @capture.to_json }
      }
    end

    def destroy
      @capture = current_user.captures.find_by! key: params[:key]

      if params[:destroy]
        @capture.update! status: :merged
      else
        @capture.destroy!
      end

      head status: 200
    end

  end
end
