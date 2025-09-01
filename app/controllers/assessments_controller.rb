class AssessmentsController < Sinatra::Base
  configure do
    set :views, 'app/views/assessments'
    set :method_override, true
  end

  # Форма создания оценки для пациента
  get '/new' do
    @patient = Patient.find(params[:patient_id])
    erb :new
  end

  # Создание оценки
  post '/' do
    @patient = Patient.find(params[:patient_id])
    @assessment = @patient.assessments.new(assessment_params.merge(created_at: Time.now))
    
    if @assessment.save
      redirect "/patients/#{@patient.id}"
    else
      erb :new
    end
  end

  private

  def assessment_params
    {
      heart_rate_mother: params[:heart_rate_mother],
      blood_pressure: params[:blood_pressure],
      respiration_rate_mother: params[:respiration_rate_mother],
      spo2: params[:spo2],
      temperature: params[:temperature],
      consciousness: params[:consciousness],
      convulsions: params[:convulsions] == 'true',
      bloody_discharge: params[:bloody_discharge],
      fetal_heart_rate: params[:fetal_heart_rate],
      umbilical_cord_prolapse: params[:umbilical_cord_prolapse] == 'true',
      delivering_baby: params[:delivering_baby] == 'true',
      symptomatic: params[:symptomatic] == 'true',
      reduced_fetal_movement: params[:reduced_fetal_movement] == 'true',
      acute_pain: params[:acute_pain] == 'true',
      acute_pain_severity: params[:acute_pain_severity],
      gestational_age: params[:gestational_age],
      contractions: params[:contractions] == 'true',
      water_breakage: params[:water_breakage] == 'true',
      irregular_contractions: params[:irregular_contractions] == 'true',
      fetal_position: params[:fetal_position],
      multiple_pregnancy: params[:multiple_pregnancy] == 'true',
      placenta_previa: params[:placenta_previa] == 'true',
      uterine_scar: params[:uterine_scar] == 'true',
      hiv: params[:hiv] == 'true',
      planned_cs: params[:planned_cs] == 'true',
      herpes: params[:herpes] == 'true',
      recent_trauma: params[:recent_trauma] == 'true',
      requires_transfer: params[:requires_transfer] == 'true',
      normal_pregnancy_complaints: params[:normal_pregnancy_complaints] == 'true',
      no_complaints: params[:no_complaints] == 'true'
    }
  end
end