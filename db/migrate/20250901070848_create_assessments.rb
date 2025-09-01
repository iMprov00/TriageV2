class CreateAssessments < ActiveRecord::Migration[6.1]
  def change
    create_table :assessments do |t|
      t.references :patient, null: false, foreign_key: true
      
      # Основные показатели матери
      t.integer :heart_rate_mother
      t.string :blood_pressure
      t.integer :respiration_rate_mother
      t.decimal :spo2, precision: 5, scale: 2
      t.decimal :temperature, precision: 5, scale: 2
      t.string :consciousness
      t.boolean :convulsions
      t.string :bloody_discharge
      t.boolean :symptomatic
      t.boolean :reduced_fetal_movement
      t.boolean :acute_pain
      t.integer :acute_pain_severity
      
      # Показатели плода
      t.integer :fetal_heart_rate
      t.boolean :umbilical_cord_prolapse
      t.boolean :delivering_baby
      
      # Акушерские данные
      t.integer :gestational_age
      t.boolean :contractions
      t.boolean :water_breakage
      t.boolean :irregular_contractions
      t.string :fetal_position
      t.boolean :multiple_pregnancy
      t.boolean :placenta_previa
      t.boolean :uterine_scar
      
      # Медицинская история
      t.boolean :hiv
      t.boolean :planned_cs
      t.boolean :herpes
      t.boolean :recent_trauma
      t.boolean :requires_transfer
      
      # Жалобы
      t.boolean :normal_pregnancy_complaints
      t.boolean :no_complaints
      
      t.timestamps
    end
  end
end