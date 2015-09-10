# coding: utf-8
require 'rubygems'
require 'daemons'

# FAMIMA program

CAPTURED_PATH = '/tmp/motion'
CAPTURED_FILEMASK = '*.jpg'
AQUESTALK_BIN = '/usr/local/bin/AquesTalkPi'
PLAYER_BIN = 'aplay'
FAMIMA_FILE = '~/dev/famima/famima.wav'
WAIT_SEC = 1 # sec

class AquesTalk
  def initialize
  end

  def talk(text)
    system("#{AQUESTALK_BIN} '#{text}' | #{PLAYER_BIN}")
  end
end

class PhotoWatch
  def initialize(path)
    # Dir.chdir(path)
    @path = path
    @photo_count = filecount
    debug("initial file count = #{@photo_count}")
  end

  def increment?
    count = filecount
    debug("now file count = #{count}")
    if @photo_count + 1 == count
      @photo_count = count
      true
    else
      @photo_count = count if @photo_count < count # more than +1
      false
    end
  end

  def watch(famima)
    famima.play if increment?
  end

  private
  def filecount
    Dir.glob("#{@path}/#{CAPTURED_FILEMASK}").count
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

pw = PhotoWatch.new(CAPTURED_PATH)

famima = FamimaSound.new

Daemons.run_proc(File.basename(__FILE__)) do
  while true
    pw.watch(famima)
    sleep WAIT_SEC
  end
end

