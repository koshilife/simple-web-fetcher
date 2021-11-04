# frozen_string_literal: true

module SimpleWebFetcher
  module Loggable
    def log(msg)
      if @logging_io.respond_to?(:write)
        @logging_io.write("#{msg}\n")
      else
        puts(msg)
      end
    end

    def log_error(msg)
      log("(ERROR) #{msg}")
    end

    def log_debug(msg)
      log("(DEBUG) #{msg}") if debug?
    end

    def log_debug_for_exception(ex)
      log_debug("#{ex.class} is occured. #{ex.message}, backtrace:\n#{ex.backtrace.join("\n")}")
    end

    def debug?
      # need to override in a class which did mix-in.
      false
    end
  end
end
