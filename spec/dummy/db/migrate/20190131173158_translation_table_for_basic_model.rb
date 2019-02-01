class TranslationTableForBasicModel < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        BasicModel.create_translation_table! title: :string
      end

      dir.down do
        BasicModel.drop_translation_table!
      end
    end
  end
end
