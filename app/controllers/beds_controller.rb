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
        time_left: calculate_time_left(latest_assessment.created_at, latest_assessment.calculate_priority)
      }
    end.compact
    
    patients.to_json
  end

  private

def calculate_time_left(assessment_time, priority)
  puts "=== TIME CALCULATION DEBUG ==="
  puts "Assessment time: #{assessment_time}"
  puts "Current time: #{Time.now}"
  puts "Priority: #{priority}"
  
  priority_times = {
    1 => 5 * 60,    2 => 15 * 60,   3 => 60 * 60,
    4 => 120 * 60,  5 => 240 * 60
  }

  time_allowed = priority_times[priority] || 240 * 60
  time_elapsed = Time.now - assessment_time
  time_left_seconds = [time_allowed - time_elapsed, 0].max

  puts "Time allowed: #{time_allowed} seconds"
  puts "Time elapsed: #{time_elapsed} seconds"  
  puts "Time left: #{time_left_seconds} seconds"
  
  minutes = (time_left_seconds / 60).to_i
  seconds = (time_left_seconds % 60).to_i

  {
    total_seconds: time_left_seconds.to_i,
    minutes: minutes,
    seconds: seconds,
    formatted: "#{minutes}:#{seconds.to_s.rjust(2, '0')}",
    critical: time_left_seconds <= 300 && time_left_seconds > 0,
    expired: time_left_seconds == 0
  }
end
end