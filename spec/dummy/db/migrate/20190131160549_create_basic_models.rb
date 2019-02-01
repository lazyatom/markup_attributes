class CreateBasicModels < ActiveRecord::Migration[5.2]
  def change
    create_table :basic_models do |t|
      t.string :type
      t.string :body

      t.timestamps
    end
  end
end
