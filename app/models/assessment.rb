# Модель оценки пациента по шкале MFTI
class Assessment < ActiveRecord::Base
  belongs_to :patient
  
  # Валидации
  validates :patient_id, presence: true
  validates :heart_rate_mother, numericality: { only_integer: true, allow_nil: true }
  validates :respiration_rate_mother, numericality: { only_integer: true, allow_nil: true }
  validates :spo2, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_nil: true }
  validates :temperature, numericality: { allow_nil: true }
  validates :fetal_heart_rate, numericality: { only_integer: true, allow_nil: true }
  validates :gestational_age, numericality: { only_integer: true, allow_nil: true }
  validates :acute_pain_severity, numericality: { only_integer: true, allow_nil: true }

  # Условия для определения приоритета (MFTI)
  PRIORITY_CONDITIONS = {
    1 => [
      ->(a) { a.heart_rate_mother && (a.heart_rate_mother < 40 || a.heart_rate_mother > 130) },
      ->(a) { a.blood_pressure_systolic && a.blood_pressure_systolic >= 160 },
      ->(a) { a.blood_pressure_diastolic && a.blood_pressure_diastolic >= 110 },
      ->(a) { a.respiration_rate_mother && a.respiration_rate_mother == 0 },
      ->(a) { a.spo2 && a.spo2 < 93 },
      ->(a) { a.temperature && (a.temperature > 41 || a.temperature < 35) },
      ->(a) { a.consciousness == 'отсутствует' },
      ->(a) { a.convulsions },
      ->(a) { a.bloody_discharge == 'алые непрерывные' },
      ->(a) { a.fetal_heart_rate && a.fetal_heart_rate <= 110 },
      ->(a) { a.umbilical_cord_prolapse },
      ->(a) { a.delivering_baby }
    ],
    2 => [
      ->(a) { a.heart_rate_mother && (a.heart_rate_mother < 50 || a.heart_rate_mother > 120) },
      ->(a) { a.blood_pressure_systolic && a.blood_pressure_systolic >= 140 && a.symptomatic },
      ->(a) { a.blood_pressure_diastolic && a.blood_pressure_diastolic >= 90 && a.symptomatic },
      ->(a) { a.respiration_rate_mother && (a.respiration_rate_mother < 12 || a.respiration_rate_mother > 26) },
      ->(a) { a.spo2 && a.spo2 <= 95 },
      ->(a) { a.temperature && a.temperature > 38.3 },
      ->(a) { a.consciousness == 'измененное' },
      ->(a) { a.bloody_discharge == 'умеренные' },
      ->(a) { a.fetal_heart_rate && a.fetal_heart_rate >= 160 },
      ->(a) { a.reduced_fetal_movement },
      ->(a) { a.acute_pain && a.acute_pain_severity && a.acute_pain_severity >= 7 },
      ->(a) { a.gestational_age && a.gestational_age < 34 && a.contractions },
      ->(a) { a.gestational_age && a.gestational_age < 34 && a.water_breakage },
      ->(a) { a.gestational_age && a.gestational_age >= 34 && 
              (a.contractions || a.water_breakage) && 
              (a.hiv || a.planned_cs || ['тазовое', 'поперечное', 'другое аномальное'].include?(a.fetal_position) || 
               a.multiple_pregnancy || a.placenta_previa) },
      ->(a) { a.recent_trauma },
      ->(a) { a.requires_transfer }
    ],
    3 => [
      ->(a) { a.blood_pressure_systolic && a.blood_pressure_systolic >= 140 && !a.symptomatic },
      ->(a) { a.blood_pressure_diastolic && a.blood_pressure_diastolic >= 90 && !a.symptomatic },
      ->(a) { a.temperature && a.temperature > 38.0 },
      ->(a) { a.contractions && a.gestational_age && a.gestational_age >= 34 },
      ->(a) { (a.irregular_contractions || a.water_breakage) && a.gestational_age && a.gestational_age >= 34 && a.gestational_age <= 36.6 },
      ->(a) { a.contractions && a.gestational_age && a.gestational_age >= 34 && a.uterine_scar },
      ->(a) { a.multiple_pregnancy && a.irregular_contractions && a.gestational_age && a.gestational_age >= 34 },
      ->(a) { a.contractions && a.gestational_age && a.gestational_age >= 30 && a.herpes }
    ],
    4 => [
      ->(a) { (a.irregular_contractions || a.water_breakage) && a.gestational_age && a.gestational_age > 37 },
      ->(a) { a.normal_pregnancy_complaints }
    ],
    5 => [
      ->(a) { a.no_complaints }
    ]
  }

  # Расчет приоритета на основе условий
  def calculate_priority
    (1..5).each do |priority|
      if PRIORITY_CONDITIONS[priority].any? { |condition| condition.call(self) }
        return priority
      end
    end
    5 # приоритет по умолчанию
  end

  # Вспомогательные методы для работы с артериальным давлением
  def blood_pressure_systolic
    return nil unless blood_pressure =~ /(\d+)\/(\d+)/
    $1.to_i
  end

  def blood_pressure_diastolic
    return nil unless blood_pressure =~ /(\d+)\/(\d+)/
    $2.to_i
  end

  # Цвет приоритета для отображения
  def priority_color
    case calculate_priority
    when 1 then 'priority-1'
    when 2 then 'priority-2'
    when 3 then 'priority-3'
    when 4 then 'priority-4'
    when 5 then 'priority-5'
    else 'priority-5'
    end
  end

  # Текстовое описание приоритета
  def priority_description
    case calculate_priority
    when 1 then 'Красный - немедленная помощь'
    when 2 then 'Оранжевый - срочная помощь'
    when 3 then 'Желтый - помощь в течение часа'
    when 4 then 'Зеленый - плановая помощь'
    when 5 then 'Синий - не требуется срочной помощи'
    else 'Не определен'
    end
  end
end