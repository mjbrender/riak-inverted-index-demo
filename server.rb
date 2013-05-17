require 'bundler/setup'
require 'sinatra'
require 'riak'

class Zombie
  attr_accessor :fields, :data

  def initialize()
    @fields = [:dna, :sex, :name, :address, :city, :state,
               :zip, :phone, :birthdate, :ssn, :job, :bloodtype,
               :weight, :height, :lattitude, :longitude]

    @data = {}
  end

  def from_array(arr)
    i = 0
    for field in @fields
      @data[field] = arr[i]
      i+=1
    end
  end
end

# Get
get '/' do
  erb :index
end

get '/2i/:zip' do
  client = Riak::Client.new

  results = client['zombies'].get_index('zip_bin', params[:zip])

  erb :query, :locals => {:results => results}
end

get '/ii/:zip' do
  results = "no"
  erb :query, :locals => {:results => results}
end

get '/load' do
  client = Riak::Client.new
  zombies = []

  File.open("data.csv") do |file|

    file.each do |line|
      fields = line.split(",")
      zombie = Zombie.new()
      zombie.from_array(fields)

      zombies << zombie.data

      riak_obj = client['zombies'].new
      riak_obj.data = zombie.data
      riak_obj.indexes['zip_bin'] << zombie.data[:zip]
      riak_obj.store
    end
  end

  erb :load, :locals => {:zombies => zombies}
end