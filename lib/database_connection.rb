require 'mysql2'
require 'yaml'

class DatabaseConnection
  # == Constants ============================================================

  DATABASE_CONFIG_FILE = 'database.yml'

  # == Class Methods ========================================================

  def self.config_path
    path = Dir.pwd
    last_path = nil

    while (path != last_path)
      config_path = File.expand_path("config/#{DATABASE_CONFIG_FILE}", path)

      if (File.exist?(config_path))
        return config_path
      end

      last_path = path
      path = File.expand_path('..', path)
    end

    nil
  end

  def self.config
    @config ||= begin
      _config_path = self.config_path

      if (!_config_path)
        STDERR.puts("Could not find #{DATABASE_CONFIG_FILE}")
        exit(-1)
      elsif (File.exists?(_config_path))
        File.open(_config_path) do |f|
          YAML.load(f)
        end
      else
        STDERR.puts "Could not open #{_config_path}"
        exit(-1)
      end
    end
  end

  def self.runtime_environment(env=nil)
    env or 'development'
  end

  def self.connect
    Mysql2::Client.new(self.config[self.runtime_environment])
  end
end