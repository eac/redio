nodes = [ Redis.new('master_1'), Redis.new('master_2'), Redis.new('master_3') ]

# Setup a cluster of servers
cluster = Redio::Cluster.new(nodes).tap do |redis|
  redis.distribute :append,   :minimum => 2 # Must succeed on at least two servers
  redis.distribute :strlen,   :limit => 1   # Return after first success
  redis.distribute :getrange, :limit => 1
end

# Upload a file to redis
digest = Digest::MD5.file('12345.txt')
begin
  Redio::TempFile.open('12345.txt', :client => cluster, :digest => digest, :expiration => 1.day) do |redis_file|
    File.open('12345.txt').each do |local_file|
      redis_file.write local_file
    end
  end
rescue => Redio::CorruptStream
  puts "Calculated digests don't match"
end

# Copy a file from Redis to S3
upload = Net::HTTP::Post.new('12345.txt').tap do |request|
  request.body_stream = Redio::TempFile.open('12345.txt', :client => cluster)
end

response = Net::HTTP.new('amazon_s3').start { |http| http.request(upload) }

