class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|

      t.timestamps null: false
    end
  end
end
