require 'bundler/setup'
Bundler.require

# Подключаем все файлы из app
require_all 'app'

# Настройка базы данных
configure :development do
  set :database, {
    adapter: 'sqlite3',
    database: 'db/development.sqlite3'
  }
end

configure :test do
  set :database, {
    adapter: 'sqlite3',
    database: 'db/test.sqlite3'
  }
end