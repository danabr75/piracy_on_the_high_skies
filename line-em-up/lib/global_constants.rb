module GlobalConstants
  CURRENT_DIRECTORY = File.expand_path('../', __FILE__)
  APP_DIRECTORY     = File.join(CURRENT_DIRECTORY, '..', '..')
  CONTENT_DIRECTORY = File.join(CURRENT_DIRECTORY, '..')


  LIB_DIRECTORY   = File.join(CONTENT_DIRECTORY, "lib")
  MAP_DIRECTORY   = File.join(CONTENT_DIRECTORY, "maps")
  SCRIPT_DIRECTORY   = File.join(CONTENT_DIRECTORY, "scripts")
  MEDIA_DIRECTORY   = File.join(CONTENT_DIRECTORY, "media")
  SOUND_DIRECTORY   = File.join(CONTENT_DIRECTORY, "sounds")
  MODEL_DIRECTORY   = File.join(CONTENT_DIRECTORY, "models")
  GENERATORS_DIRECTORY   = File.join(CONTENT_DIRECTORY, "generators")
  DIALOGUE_DIRECTORY   = File.join(CONTENT_DIRECTORY, "dialogues")

  VENDOR_LIB_DIRECTORY  = File.join(CONTENT_DIRECTORY, "vendors", "lib")

  SAVE_FILE_DIRECTORY           = File.join(APP_DIRECTORY, "save_files")

  CURRENT_SAVE_FILE           = File.join(SAVE_FILE_DIRECTORY, "current.txt")

  CONFIG_FILE           = File.join(SAVE_FILE_DIRECTORY, "config.txt")

end