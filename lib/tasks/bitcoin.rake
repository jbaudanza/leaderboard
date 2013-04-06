desc 'Reads the `addressess` file and adds it to the database'
task :import_addresses => :environment do
  count = 0
  File.open('addresses', 'r') do |file|
    until file.eof?
      address = file.readline.chomp

      if Bitcoin::valid_address?(address)
        result = ValidationAddress.create!(:address => address)
        count += 1 if result
      else
        puts "Skipping invalid address: #{address}"
      end
    end
  end
  puts "Imported #{count} addresses"
end

desc 'Generate keys.json and addresses files'
task :generate_keypairs do
  require 'json'

  keys = 1000.times.collect do
    private_key, public_key = Bitcoin::generate_key
    address = Bitcoin::pubkey_to_address(public_key)
    {
      'private_key' => private_key,
      'public_key' => public_key,
      'address' => address
    }
  end

  %w(keys.json addresses).each do |filename|
    raise "File already exists: #{filename}" if File.exists?(filename)
  end

  puts "Writing file keys.json"
  File.open('keys.json', 'w') do |file|
    file.puts keys.to_json
  end

  puts "Writing file addresses"
  File.open('addresses', 'w') do |file|
    keys.each do |item|
      file.puts item['address']
    end
  end
end