module API
  class CapturesController < API::BaseController

    before_filter -> { require_scope! :capture }

    def index
      @captures = index_filter.order created_at: :asc
      respond_to { |format|
        format.org  { render body: @captures.pluck(:content).join("\n\n") }
        format.json { render json: @captures }
      }
    end

    def index_filter
      case params[:status]
      when "merged"
        current_user.captures.merged
      when "all"
        current_user.captures
      else
        current_user.captures.pending
      end
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

    def destroy
      @capture = current_user.captures.find_by! key: params[:id]
      @capture.update! status: :merged unless params[:force]
      @capture.destroy! if params[:force]

      head status: 200
    end

  end
end
