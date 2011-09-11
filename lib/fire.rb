# This is based on Simon Jefford's FirebugLogger
# See here: http://github.com/simonjefford/rack_firebug_logger
# 
# The functionality has changed to send FirePHP headers rather
# than injecting scripts in the response body.
# This means any resource can have logging sent back with it.
require 'json'
class Fire

  FLAG = 'firebug.logs'

  def initialize(app, options = {})
    @app = app
    @options = options
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers.merge! collect_headers(env) if meets_fire_criteria(headers, env)
    [status, headers, body]
  end

  private

  TYPES = {
    :log   => "LOG",
    :info  => "INFO",
    :warn  => "WARN",
    :error => "ERROR"
  }

  def collect_headers(env)
    logged_items = env[FLAG]

    headers = {}
    headers["X-Wf-Protocol-1"] = "http://meta.wildfirehq.org/Protocol/JsonStream/0.2"
    headers["X-Wf-1-Plugin-1"] = "http://meta.firephp.org/Wildfire/Plugin/FirePHP/Library-FirePHPCore/0.3"
    headers["X-Wf-1-Structure-1"] = "http://meta.firephp.org/Wildfire/Structure/FirePHP/FirebugConsole/0.1"

    count = 1
    logged_items.each do |type, obj|
      next if !(type.to_s =~ /^(log|info|warn|error)$/)
      msg = "[#{{ "Type" => TYPES[type] }.to_json},#{obj.to_json}]"
      headers["X-Wf-1-1-1-#{count}"] = "#{msg.length}|#{msg}|"
      count+=1
    end
    headers
  end

  def meets_fire_criteria(headers, env)
    headers["Content-Type"] =~ /html/ && env['firebug.logs']
  end

  def generate_js(logs)
    js = ["<script type=\"text/javascript\">"]
    start_group(js)
    logs.each do |level, log|
      level = sanitise_level(level)
      log.gsub!('"', '\"')
      js << "console.#{level.to_s}(\"#{log}\");"
    end
    end_group(js)
    js << "</script>"
    js << "</body>"
    js.join("\n")
  end

  def start_group(js)
    if @options[:group]
      js << "console.group(\"#{@options[:group]}\");"
    end
  end

  def sanitise_level(level)
    if [:info, :debug, :warn, :error].include?(level)
      level
    else
      :debug
    end
  end

  def end_group(js)
    if @options[:group]
      js << "console.groupEnd();"
    end
  end
end