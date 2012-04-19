class Flock < ActiveRecord::Base
  attr_accessible :align, :avoid, :boids, :boidsize, :center, :goalseek, :height, :jitter, :name, :width
end
