require_relative 'data_center'
dc2 = DataCenter.new('dc2','169.231.10.109')
t2 = Thread.new do
  dc2.run
end

t2.join