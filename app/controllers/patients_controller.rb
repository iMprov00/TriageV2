class PatientsController < Sinatra::Base
  configure do
    set :views, 'app/views/patients'
    set :method_override, true
    set :protection, except: [:authenticity_token] # Отключаем проверку CSRF
  end

  # Список всех пациентов
  get '/' do
    @patients = Patient.all
    erb :index
  end

  # Форма создания нового пациента
  get '/new' do
    erb :new
  end

  # Просмотр конкретного пациента
  get '/:id' do
    @patient = Patient.find(params[:id])
    erb :show
  end

  # Создание пациента
  post '/' do
    @patient = Patient.new(
      full_name: params[:full_name],
      date_of_birth: params[:date_of_birth],
      admission_time: params[:admission_time]
    )

    if @patient.save
      redirect "/patients/#{@patient.id}"
    else
      erb :new
    end
  end

  # Форма редактирования
  get '/:id/edit' do
    @patient = Patient.find(params[:id])
    erb :edit
  end

  # Обновление пациента
  put '/:id' do
    @patient = Patient.find(params[:id])
    if @patient.update(
      full_name: params[:full_name],
      date_of_birth: params[:date_of_birth],
      admission_time: params[:admission_time]
    )
      redirect "/patients/#{@patient.id}"
    else
      erb :edit
    end
  end

  # Удаление пациента
  delete '/:id' do
    @patient = Patient.find(params[:id])
    @patient.destroy
    redirect '/patients'
  end

  post '/:id/toggle_monitor' do
    content_type :json
    
    begin
      # Парсим JSON тело запроса
      request_body = JSON.parse(request.body.read)
      on_monitor = request_body['on_monitor']
      
      @patient = Patient.find(params[:id])
      
      if @patient.update(on_monitor: on_monitor)
        { success: true, on_monitor: @patient.on_monitor }.to_json
      else
        status 500
        { success: false, errors: @patient.errors.full_messages }.to_json
      end
    rescue JSON::ParserError
      status 400
      { success: false, error: 'Invalid JSON' }.to_json
    rescue ActiveRecord::RecordNotFound
      status 404
      { success: false, error: 'Patient not found' }.to_json
    rescue => e
      status 500
      { success: false, error: e.message }.to_json
    end
  end
end  # Конец класса - это важно!