# frozen-string-literal: true

module Shink::BaseLibrary::Down
  class Backend
    def self.download(*args, &block)
      new.download(*args, &block)
    end

    def self.open(*args, &block)
      new.open(*args, &block)
    end

    private

    def download_result(tempfile, destination)
      if destination
        tempfile.close
        FileUtils.mv tempfile.path, destination
        nil
      else
        tempfile
      end
    end
  end
end
