module SHINK_LIBRARY
  IsWindows = !(RUBY_PLATFORM =~ /darwin/i)
  IsDevelop = !__FILE__.include?('SketchUp/Plugins')
  MainThread = Thread.current
  SuVersion = Sketchup.version.split('.').first.to_i
  DocumentsPath = ENV['HOME']
  if IsWindows
    require 'win32/registry'
    ie_version1 = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Microsoft\Internet Explorer'){|reg| reg['svcVersion'].split('.').first.to_i} rescue nil
    ie_version2 = Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Wow6432Node\Microsoft\Internet Explorer'){|reg| reg['svcVersion'].split('.').first.to_i} rescue nil
    IEVersion = ie_version1 || ie_version2 || 0
  end
end
