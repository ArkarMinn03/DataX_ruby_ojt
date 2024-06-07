class UserDecorator < Draper::Decorator
  delegate_all

  def formated_full_name
    object.first_name + ' ' + object.last_name
  end

  def formated_created_at
    object.created_at&.strftime("%d-%m-%y")
  end

  def formated_updated_at
    object.updated_at&.strftime("%d-%m-%y")
  end

  def gender_type
    if object.gender == 0
      'Male'
    else
      'Female'
    end
  end
end