require 'zlib'
require 'yaml'

class Split

  # == Instance Methods =====================================================
  def initialize(options)
    @chunksize = options[:chunk_size].to_i
    @filepath = options[:filepath]
    @temp_file_path = '../chunk.csv'
    @db = DatabaseConnection.connect
    @table = options[:table]
    @debug = options[:debug]
    @timer = options[:timer]

    File.open(File.expand_path("config/rules.yml")) do |f|
       @ruleset = YAML.load(f)
       @rules = @ruleset.map {|k, v| self.send(v.to_sym, k.to_s)}.compact.join(", ")
    end

    @insert_rate = []
  end

  def debug
    if (@debug)
      yield
    end
  end

  def size

    case @filepath
    when /\.gz\z/
      size = `gunzip -dc "#{@filepath}" | wc -l`.strip.split(' ')[0].to_i
    else
      size = `wc -l "#{@filepath}"`.strip.split(' ')[0].to_i
    end

    if size < @chunksize
      1
    else
      (size / @chunksize).ceil
    end
  end

  def min(attribute)
    "%{cn} = IF(%{tn}.%{cn} IS NULL,values(%{cn}),IF(values(%{cn}) IS NULL, %{tn}.%{cn}, LEAST(%{tn}.%{cn},values(%{cn}))))" % {cn: attribute, tn: @table}
  end

  def max(attribute)
    "%{cn} = IF(%{tn}.%{cn} IS NULL,values(%{cn}),IF(values(%{cn}) IS NULL, %{tn}.%{cn}, GREATEST(%{tn}.%{cn},values(%{cn}))))" % {cn: attribute, tn: @table}
  end

  def sum(attribute)
    "%{cn} = IF(%{tn}.%{cn} IS NULL,values(%{cn}),IF(values(%{cn}) IS NULL, %{tn}.%{cn}, %{tn}.%{cn} + values(%{cn})))" % {cn: attribute, tn: @table}
  end

  def ignore(attribute)
    nil
  end

  def open_csv(path, &block)
    case path
    when /\.gz\z/
      Zlib::GzipReader.open(path, &block)
    else
      File.open(path, &block)
    end
  end

  def timer(start, finished)
    @insert_rate << @chunksize / (finished - start)
    puts "average inserting %s per second" % (@insert_rate.reduce(:+) / @insert_rate.size if @timer).ceil if @timer
  end

  def insert
    columns = @ruleset.keys.join(', ')

    start = Time.now
    query =
      "LOAD DATA LOCAL INFILE '%s'
       INTO TABLE temp_%s
       FIELDS TERMINATED BY ','
       ENCLOSED BY '\"'
       LINES TERMINATED BY '\n'" % [@temp_file_path, @table]

    debug do
      puts "SQL > %s" % query
    end

    @db.query(query)


    query =
      "INSERT INTO %{tn} (%{c})
       SELECT %{c}
       FROM temp_%{tn}
       ON DUPLICATE KEY UPDATE %{r}" % {
        tn: @table,
        r: @rules,
        c: columns
      }

    debug do
      puts "SQL > %s" % query
    end

    @db.query(query)

    finish = Time.now

    timer(start,finish) if @timer

  end

  def split
    chunk_count = 0
    # create a temp table to hold data
    @db.query("CREATE TEMPORARY TABLE temp_%s LIKE %s" % [@table, @table])

    chunks = size

    open_csv(@filepath) do |f|
      f.each_line.each_slice(@chunksize).with_index(1) do |rows, i|
        puts "Inserting chunk %s/%s" % [i, chunks]
        debug do
          puts "chunk %d > %s" % [i, rows]
        end
        File.open(@temp_file_path, 'w') do |chunk|
          @db.query("TRUNCATE TABLE temp_%s" % @table)
          chunk.write(rows.join)
          chunk.close
          insert
        end
      end
    end

    puts 'Finish'
  end
end

require_relative './database_connection'