require_relative 'config/environment'
require_relative 'app/controllers/patients_controller'
require_relative 'app/controllers/assessments_controller' 
require_relative 'app/controllers/beds_controller'

map('/') { run ApplicationController }
map('/patients') { run PatientsController }
map('/assessments') { run AssessmentsController }
map('/beds') { run BedsController }