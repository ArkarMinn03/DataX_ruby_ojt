class EventsController < ApplicationController
  before_action :set_event, only: %i[ show edit update destroy ]

  def index
    @events = Event.all.decorate
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    respond_to do |format|
      begin
        event_create_usecase = Events::EventUsecase.new(event_params)
        response = event_create_usecase.create
        if response[:status] == :created
          format.html { redirect_to events_path, notice: t("messages.common.create_success", data: "Event") }
        else
          flash[:errors] = response[:errors]
          format.html { redirect_to new_event_path, status: :unprocessable_entity, event: response[:event], errors: response[:errors] }
        end
      rescue StandardError => errors
        logger.error "Something went wrong while creating event. #{ errors.message }"
        format.html { render file: "#{ Rails.root }/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  def edit
    @event.start_date_part = @event.start_time.to_date
    @event.start_time_part = @event.start_time.strftime('%H:%M')
    @event.end_date_part = @event.end_time.to_date
    @event.end_time_part = @event.end_time.strftime('%H:%M')
  end

  def update
    update_event = Events::EventUsecase.new(event_params)
    respond_to do |format|
      if (update_event.update(@event))
        format.html { redirect_to @event, notice: t('messages.common.update_success', data: "Event") }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    delete_event = Events::EventUsecase.new(nil)

    respond_to do |format|
      if delete_event.destroy(@event)
        format.html { redirect_to events_url, notice: t('messages.common.destroy_success', data: "Event") }
        format.json { head :no_content }
      end
    end
  end

  private
    def event_params
      params.require(:event).permit(:title, :description, :start_date_part, :start_time_part, :end_date_part, :end_time_part)
    end

    def set_event
      @event = Event.find(params[:id]).decorate
    end
end