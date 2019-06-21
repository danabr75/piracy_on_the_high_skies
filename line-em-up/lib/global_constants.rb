module GlobalConstants
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  APP_DIRECTORY     = File.join(CURRENT_DIRECTORY, '..', '..')
  LIB_DIRECTORY   = File.join(APP_DIRECTORY, "line-em-up/lib")
  MEDIA_DIRECTORY   = File.join(APP_DIRECTORY, "line-em-up/media")
  SOUND_DIRECTORY   = File.join(APP_DIRECTORY, "line-em-up/sounds")
  MODEL_DIRECTORY   = File.join(APP_DIRECTORY, "line-em-up/models")
  VENDOR_LIB_DIRECTORY  = File.join(APP_DIRECTORY, "vendors", "lib")
  CONFIG_FILE           = File.join(APP_DIRECTORY, "config.txt")
end