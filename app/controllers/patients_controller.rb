class PatientsController < Sinatra::Base
  configure do
    set :views, 'app/views/patients'
    set :method_override, true
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
end

post '/:id/toggle_monitor' do
  @patient = Patient.find(params[:id])
  if @patient.update(on_monitor: params[:on_monitor])
    status 200
  else
    status 500
  end
end

