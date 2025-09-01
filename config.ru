require_relative 'config/environment'

# Подключаем контроллеры
require_relative 'app/controllers/patients_controller'
require_relative 'app/controllers/assessments_controller'
require_relative 'app/controllers/beds_controller'

# Маппинг маршрутов
map('/patients') { run PatientsController }
map('/assessments') { run AssessmentsController }
map('/beds') { run BedsController }
map('/') { run ApplicationController }