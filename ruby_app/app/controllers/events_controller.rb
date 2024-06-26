require 'csv'

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :set_users, only: %i[new create]

  def index
    @events = Event.all.order('start_time').decorate
  end

  def show
    @users = User.all.decorate
  end

  def import
    file = params[:file]
    csv_import_usecase = CsvUsecase.new(file)
    response = csv_import_usecase.import
    if response[:status] == :ok
      redirect_to events_path, notice: "Events imported success!"
    end
  end

  def export_all
    @events = Event.all
    export_all_service = Events::EventService.new(nil)
    csv_data = export_all_service.export_all(@events)

    respond_to do |format|
      format.csv do
        send_data csv_data, filename: 'events.csv', type: 'text/csv'
      end
    end
  end

  def export
    @event = Event.find(params[:event_id])
    event_export_service = Events::EventService.new(nil)
    csv_data = event_export_service.export(@event)

    respond_to do |format|
      format.csv { send_data csv_data, filename: "event_#{@event.title}.csv", type: "text/csv" }
    end
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
          flash[:alert] = t("messages.common.create_fail", data: "Event")
          @event = response[:event]
          format.html { render :new, status: :unprocessable_entity, errors: response[:errors]}
        end
      rescue StandardError => errors
        logger.error "Something went wrong while creating the event. #{ errors.message }"
        format.html { render file: "#{ Rails.root }/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  def edit
    @event.start_date_part = @event.start_time.to_date
    @event.start_time_part = @event.start_time.strftime('%H:%M')
    @event.end_date_part = @event.end_time.to_date
    @event.end_time_part = @event.end_time.strftime('%H:%M')
    @users = User.all.decorate
    @guest_ids = @event.event_guests.pluck(:user_id)
  end

  def update
    update_event = Events::EventUsecase.new(event_params)
    respond_to do |format|
      response = update_event.update(@event)
      if response[:status] == :updated
        format.html { redirect_to @event, notice: t('messages.common.update_success', data: "Event") }
        format.json { render :show, status: :ok, location: @event }
      else
        @event.start_date_part = @event.start_time.to_date
        @event.start_time_part = @event.start_time.strftime('%H:%M')
        @event.end_date_part = @event.end_time.to_date
        @event.end_time_part = @event.end_time.strftime('%H:%M')
        @users = User.all.decorate
        @guest_ids = @event.event_guests.pluck(:user_id)
        flash.now[:alert] = t('messages.common.update_fail', data: "Event")
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
      params.require(:event).permit(:title, :description, :start_date_part, :start_time_part, :end_date_part, :end_time_part, guest_ids: [])
    end

    def set_event
      @event = Event.find(params[:id]).decorate
    end

    def set_users
      @users = User.all.order('first_name').decorate
      @guest_ids = []
    end
end