# coding: utf-8
require 'rubygems'
require 'daemons'

#= FAMIMA program
#Authors:: Tsubasa Ogawa
#Version:: 1.0

# ------------- Settings ------------- # 

# Path to a sound player
PLAYER_BIN = 'aplay'

# Path for a log file
FAMIMAD_LOG = '/tmp/famimad_log'

# Path to the log file which MOTION outputs
WATCHING_FILE = '/tmp/motion_triggered.log'

# Path to famima sound
FAMIMA_FILE = '/home/pi/dev/famima/famima.wav'

# Minimum time between triggers (sec.)
MIN_TRIGGER_TIME = 15

# A loop interval (sec.)
WAIT_SEC = 1

# ------------------------------------ #

# Watching the log file outputted by motion
class MotionWatch
  def initialize
    @modified_time = 0
  end

  def triggered?
    return false if ! File.exist?(WATCHING_FILE)

    # get timestamps of the log file
    file = File::stat(WATCHING_FILE)
    new_modified_time = file.mtime.to_i # sec (total)

    # modified (equals: motion detected)
    if @modified_time != new_modified_time and (new_modified_time - @modified_time) > MIN_TRIGGER_TIME
      @modified_time = new_modified_time
      debug("motion triggered at #{new_modified_time}")
      true
    else
      false
    end
  end
end

# playing famima sound
class FamimaSound
  def initialize
  end

  def play
    system("#{PLAYER_BIN} #{FAMIMA_FILE}")
    debug("played")
  end
end

# for debugging
def debug(text)
  # STDERR.puts(text)
  system("echo #{text} >> #{FAMIMAD_LOG}")
end

# main proc.
Daemons.run_proc(File.basename(__FILE__)) do

  # initialize
  mw = MotionWatch.new
  famima = FamimaSound.new

  # infinite loop
  loop do
    famima.play if mw.triggered?
    sleep WAIT_SEC
  end
end

