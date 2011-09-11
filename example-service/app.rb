require 'rubygems'
require 'sinatra/base'

require '../lib/fire.rb'

class MyApp < Sinatra::Base

  use Fire

  get '/' do
    log("Hello from firephp")
    info("This is an information")
    warn("This is a warning")
    error("This is an error")

    html = logged_items.map { |type, msg| "<p><span class='type'>#{type}</span> #{msg}</p>" }
    html = html.join("\n")

    <<-body
    <!DOCTYPE html>
    <html>
      <head>
        <style type="text/css">
          h1          { font    : bold 2em sans-serif; }
          p           { font    : bold 1em sans-serif; }
          .type       { color   : #666; }
          .type:after { content : ":";  }
        </style>
        <title>FirePHP headers</title>
      <body>
        <h1>FirePHP headers</h1>
        <p>Open the web inspector and you should see the following FirePHP log messages.</p>
        #{html}
      </body>
    body
  end

  LOG   = :log
  WARN  = :warn
  ERROR = :error
  INFO  = :info

  def log(message)
    log_item(LOG, message)
  end

  def warn(message)
    log_item(WARN, message)
  end

  def error(message)
    log_item(ERROR, message)
  end

  def info(message)
    log_item(INFO, message)
  end

  def log_item(type, message)
    env['firebug.logs'] = [] unless env['firebug.logs']
    env['firebug.logs'] << [type, message]
  end

  def logged_items
    env['firebug.logs']
  end
end