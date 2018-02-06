module OstackUtil
  # Public: Provides a static singleton instance to the log which can be accessed by any class.
  #
  # output_location - path  and name of the of the log file
  # level - level of logging by default is WARN.
  #
  # Returns a static singleton instance of the log
  def self.create_log(output_location = nil, level = Logger::WARN)

    log = Logger.new(output_location || STDOUT).tap do |l|

      next unless l

      l.level = level

      l.datetime_format = '%d/%m/%Y %I:%M:%S'

      l.formatter = proc { |severity, datetime, _progname, msg| "#{severity}: #{datetime} - #{msg}\n" }
    end

    log.level = level if level < log.level

    log
  end

  # Public:  This static function decides where to log the messages
  # this decision is influenced by the developer who gives
  # the ouput location.
  #
  # msg - the message to be logged
  # output -the location to log to passed as a symbol
  # if :BOTH is passed then the message is logged to console and file
  #
  # Example : OstackUtil.log('tenant does not exists',:BOTH)
  def self.log(msg, output = nil)
    if output == :FATAL
      $STD_LOG.fatal(msg)
      $FILE_LOG.fatal(msg)
    else
      $STD_LOG.info(msg) if output == :BOTH
      $FILE_LOG.debug(msg)
    end
  end
end
