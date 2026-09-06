require 'fileutils'

module DirectoryCleanup
  EXPIRATION_SECONDS = 86_400

  def self.remove(directory)
    FileUtils.rm_rf(directory)
  end

  def self.remove_expired(exercises_folder)
    expiration_time = Time.now - EXPIRATION_SECONDS
    Dir.children(exercises_folder).each do |entry|
      next unless entry.match?(/\d/)

      directory = File.join(exercises_folder, entry)
      next unless File.directory?(directory)

      created_at = File.birthtime(directory)
      remove(directory) if created_at < expiration_time
    rescue NotImplementedError
      remove(directory) if File.mtime(directory) < expiration_time
    end
  end
end

