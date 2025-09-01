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
        priority: latest_assessment.calculate_priority,
        assessment_time: latest_assessment.created_at.iso8601,
        time_left: calculate_time_left(patient.admission_time, latest_assessment.calculate_priority)
      }
    end.compact
    
    patients.to_json
  end

  private

  def calculate_time_left(admission_time, priority)
    priority_times = {
      1 => 15 * 60,  # 15 минут в секундах
      2 => 30 * 60,  # 30 минут в секундах
      3 => 60 * 60,  # 60 минут в секундах
      4 => 120 * 60, # 120 минут в секундах
      5 => 240 * 60  # 240 минут в секундах
    }

    time_allowed = priority_times[priority] || 240 * 60
    time_elapsed = Time.now - admission_time
    time_left_seconds = [time_allowed - time_elapsed, 0].max

    {
      total_seconds: time_left_seconds.to_i,
      minutes: (time_left_seconds / 60).to_i,
      seconds: (time_left_seconds % 60).to_i,
      critical: time_left_seconds < 300, # 5 минут - критическое время
      expired: time_left_seconds == 0
    }
  end
end