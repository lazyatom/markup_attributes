class AddSecondAttributeToBasicModels < ActiveRecord::Migration[5.2]
  def change
    add_column :basic_models, :summary, :string
  end
end
