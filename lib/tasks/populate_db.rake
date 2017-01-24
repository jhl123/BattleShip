namespace :populate_db do

  task :create_ships => :environment do

    if Ship.count == 0
      Ship.create(name: "Aircraft Carrier", length: 5)
      Ship.create(name: "Battleship", length: 4)
      Ship.create(name: "Submarine", length: 3)
      Ship.create(name: "Cruiser", length: 3)
      Ship.create(name: "Destroyer", length: 2)
      puts "Created 5 ships"
    else
      puts "Ships already exists"
    end
  end

end