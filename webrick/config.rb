module Shink::WEBrick
  module Config
    LIBDIR = File::dirname(__FILE__) # :nodoc:

    General = {
      :ServerName     => Utils::getservername,
      :BindAddress    => nil,   # "0.0.0.0" or "::" or nil
      :Port           => nil,   # users MUST specify this!!
      :MaxClients     => 100,   # maximum number of the concurrent connections
      :ServerType     => nil,   # default: WEBrick::SimpleServer
      :Logger         => nil,   # default: WEBrick::Log.new
      :ServerSoftware => "WEBrick/#{VERSION} " +
                         "(Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE})",
      :TempDir        => ENV['TMPDIR']||ENV['TMP']||ENV['TEMP']||'/tmp',
      :DoNotListen    => false,
      :StartCallback  => nil,
      :StopCallback   => nil,
      :AcceptCallback => nil,
      :DoNotReverseLookup => nil,
      :ShutdownSocketWithoutClose => false,
    }

    HTTP = General.dup.update(
      :Port           => 80,
      :RequestTimeout => 30,
      :HTTPVersion    => HTTPVersion.new("1.1"),
      :AccessLog      => nil,
      :MimeTypes      => HTTPUtils::DefaultMimeTypes,
      :DirectoryIndex => ["index.html","index.htm","index.cgi","index.rhtml"],
      :DocumentRoot   => nil,
      :DocumentRootOptions => { :FancyIndexing => true },
      :RequestCallback => nil,
      :ServerAlias    => nil,
      :InputBufferSize  => 65536, # input buffer size in reading request body
      :OutputBufferSize => 65536, # output buffer size in sending File or IO

      # for HTTPProxyServer
      :ProxyAuthProc  => nil,
      :ProxyContentHandler => nil,
      :ProxyVia       => true,
      :ProxyTimeout   => true,
      :ProxyURI       => nil,

      :CGIInterpreter => nil,
      :CGIPathEnv     => nil,

      # workaround: if Request-URIs contain 8bit chars,
      # they should be escaped before calling of URI::parse().
      :Escape8bitURI  => false
    )

    FileHandler = {
      :NondisclosureName => [".ht*", "*~"],
      :FancyIndexing     => false,
      :HandlerTable      => {},
      :HandlerCallback   => nil,
      :DirectoryCallback => nil,
      :FileCallback      => nil,
      :UserDir           => nil,  # e.g. "public_html"
      :AcceptableLanguages => []  # ["en", "ja", ... ]
    }

    BasicAuth = {
      :AutoReloadUserDB     => true,
    }

    DigestAuth = {
      :Algorithm            => 'MD5-sess', # or 'MD5'
      :Domain               => nil,        # an array includes domain names.
      :Qop                  => [ 'auth' ], # 'auth' or 'auth-int' or both.
      :UseOpaque            => true,
      :UseNextNonce         => false,
      :CheckNc              => false,
      :UseAuthenticationInfoHeader => true,
      :AutoReloadUserDB     => true,
      :NonceExpirePeriod    => 30*60,
      :NonceExpireDelta     => 60,
      :InternetExplorerHack => true,
      :OperaHack            => true,
    }
  end
end
