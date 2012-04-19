class CreateFlocks < ActiveRecord::Migration
  def change
    create_table :flocks do |t|
      t.string :name
      t.decimal :avoid
      t.decimal :align
      t.decimal :center
      t.decimal :jitter
      t.decimal :goalseek
      t.integer :boids
      t.integer :boidsize
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
