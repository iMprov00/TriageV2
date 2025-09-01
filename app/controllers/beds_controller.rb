class BedsController < Sinatra::Base
  configure do
    set :views, 'app/views/beds'
  end

  # Страница мониторинга с отдельным layout
  get '/' do
    @patients = Patient.where(on_monitor: true).includes(:assessments)
    erb :index, layout: :layout_monitor
  end

  # API для получения данных мониторинга
  get '/data' do
    content_type :json
    
    patients = Patient.where(on_monitor: true).includes(:assessments).map do |patient|
      latest_assessment = patient.assessments.last
      next unless latest_assessment
      
      {
        id: patient.id,
        full_name: patient.full_name,
        admission_time: patient.admission_time.iso8601,
        admission_time_formatted: format_datetime(patient.admission_time),
        priority: latest_assessment.calculate_priority,
        assessment_time: latest_assessment.created_at.iso8601,
        assessment_time_formatted: format_datetime(latest_assessment.created_at),
        time_left: calculate_time_left(latest_assessment.created_at, latest_assessment.calculate_priority)
      }
    end.compact
    
    patients.to_json
  end

  private

  def calculate_time_left(assessment_time, priority)
    priority_times = {
      1 => 5 * 60,    2 => 15 * 60,   3 => 60 * 60,
      4 => 120 * 60,  5 => 240 * 60
    }

    time_allowed = priority_times[priority] || 240 * 60
    time_elapsed = Time.now - assessment_time
    time_left_seconds = [time_allowed - time_elapsed, 0].max

    # Форматирование времени в ЧЧ:ММ:СС
    hours = (time_left_seconds / 3600).to_i
    minutes = ((time_left_seconds % 3600) / 60).to_i
    seconds = (time_left_seconds % 60).to_i

    {
      total_seconds: time_left_seconds.to_i,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      formatted: sprintf("%02d:%02d:%02d", hours, minutes, seconds),
      critical: time_left_seconds <= 300 && time_left_seconds > 0,
      expired: time_left_seconds == 0
    }
  end

  # Простое форматирование даты без изменений часового пояса
  def format_datetime(datetime)
    datetime.strftime("%d.%m.%Y, %H:%M:%S")
  end
end