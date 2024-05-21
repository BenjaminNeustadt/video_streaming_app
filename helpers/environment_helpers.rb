module EnvironmentHelpers

  # MESSAGES = {
  #   sucessful_dev_config: -> {puts "successfully configured for DEV env".colorize(:light_green)},
  #   sucessful_prod_config: -> {puts "successfully configured for PROD env".colorize(:light_green)}
  # }
  # This is identical more or less to below

  ENV_NOTICE = ->(settings) do

    if settings.environment == :development
      puts "Running in development environment".colorize(:purple)
    elsif settings.environment == :production
      puts "Running in production environment".colorize(:blue)
    else
      puts "Unknown environment".colorize(:red)
    end

  end
end