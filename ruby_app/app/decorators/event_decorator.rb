class EventDecorator < Draper::Decorator
  delegate_all

  def formated_start_time
    object.start_time&.strftime("%b %e, %Y - %I:%M %p");
  end

  def formated_end_time
    object.end_time&.strftime("%b %e, %Y - %I:%M %p");
  end
end