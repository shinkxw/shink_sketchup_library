module Shink::WEBrick
  module HTTPServlet
    FileHandler.add_handler("rhtml", ERBHandler)
  end
end
