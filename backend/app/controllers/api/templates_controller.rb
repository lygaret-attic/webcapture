module API
  class TemplatesController < API::BaseController

    before_filter -> { require_scope! :template }

    def index
      @templates = current_user.templates.all
      respond_to { |format|
        format.json { render json: @templates.to_json }
      }
    end

    def show
      @template = current_user.templates.find_by! key: params[:id]
      respond_to { |format|
        format.json { render json: @template }
        format.frag { render body: @template.tokenized.to_json }
      }
    end

    def create
      template_params = params.require(:template).permit(:template)
      template_params.merge! user_id: current_user.id

      # .new + .properties= + .save! to get around arbitrary keys in the params
      @template = Template.new template_params
      @template.properties = params.require(:template)[:properties]
      @template.save!

      respond_to { |format|
        format.json { render status: 201, json: @template }
        format.xml  { render status: 201, xml: @template }
      }
    end

    def update
      @template = current_user.templates.find_by! key: params[:id]

      update = params.require(:template).permit(:template)
      update.each { |(key, value)|
        @template[key] = value
      }

      props = params.require(:template)[:properties] || {}
      props.each { |(key, value)|
        if value == "__delete"
          @template.properties.delete(key)
        else
          @template.properties[key] = value
        end
      }

      @template.save!

      respond_to { |format|
        format.json { render json: @template }
        format.xml  { render xml: @template }
      }
    end

    def destroy
      @template = current_user.templates.find_by! key: params[:id]
      @template.destroy!

      head status: 200
    end

  end
end
