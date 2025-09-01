class Patient < ActiveRecord::Base
  has_many :assessments, dependent: :destroy
  
  validates :full_name, presence: true
  validates :admission_time, presence: true
  validates :date_of_birth, presence: true
  
  # Последняя оценка пациента
  def latest_assessment
    assessments.order(created_at: :desc).first
  end
  
  # Текущий приоритет пациента
  def current_priority
    latest_assessment&.calculate_priority || 5
  end
  
  # Цвет приоритета для отображения
  def priority_color
    latest_assessment&.priority_color || 'gray'
  end
  
  # Оставшееся время для принятия мер
  def time_remaining
    latest_assessment&.time_remaining
  end

  # Время поступления в формате для отображения
  def admission_time_formatted
    admission_time.strftime("%H:%M:%S")
  end

  # Дата рождения в формате для отображения
  def date_of_birth_formatted
    date_of_birth.strftime("%d.%m.%Y")
  end
  
  # Для JSON представления (для динамического обновления)
  def to_json(options = {})
    {
      id: id,
      full_name: full_name,
      date_of_birth: date_of_birth_formatted,
      admission_time: admission_time_formatted,
      priority: current_priority,
      priority_color: priority_color,
      time_remaining: time_remaining,
      assessment_time: latest_assessment&.created_at_formatted,
      created_at: created_at
    }.to_json(options)
  end
end