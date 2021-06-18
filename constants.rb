module SHINK_LIBRARY
  IsWindows = !(RUBY_PLATFORM =~ /darwin/i)
  IsDevelop = !__FILE__.include?('SketchUp/Plugins')
  MainThread = Thread.current
  SuVersion = Sketchup.version.split('.').first.to_i
  DocumentsPath = ENV['HOME'].encode('UTF-8')
end
