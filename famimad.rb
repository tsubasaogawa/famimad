# coding: utf-8
require 'rubygems'
require 'daemons'

# FAMIMA program

AQUESTALK_BIN = '/usr/local/bin/AquesTalkPi'
PLAYER_BIN = 'aplay'
WATCHING_FILE = '/tmp/famimad.log'
FAMIMA_FILE = './famima.wav'
WAIT_SEC = 1 # sec

class AquesTalk
  def initialize
  end

  def talk(text)
    system("#{AQUESTALK_BIN} '#{text}' | #{PLAYER_BIN}")
  end
end

class MotionWatch
  def initialize
    @modified_time = nil
  end

  def triggered?
    file = File::stat(WATCHCING_FILE)
    new_modified_time = file.mtime.to_s
    if @modified_time != new_modified_time
      @modified_time = new_modified_time
      true
    else
      false
    end
  end
end

class FamimaSound
  def initialize
  end

  def play
    system("#{PLAYER_BIN} #{FAMIMA_FILE}")
    debug("played")
  end
end

def debug(text)
  # STDERR.puts(text)
end

# initialize
_, term, = ARGV
term = term.to_i

aquestalk = AquesTalk.new
aquestalk.talk("kidou kanryou!")

mw = MotionWatch.new
famima = FamimaSound.new

Daemons.run_proc(File.basename(__FILE__)) do
  while true
    famima.play if mw.triggered?
    sleep WAIT_SEC
  end
end

