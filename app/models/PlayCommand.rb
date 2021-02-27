require 'net/http'
require 'uri'

class PlayCommand
    ROOT_QUERY = '/vlc?'
    #HOST_MUSIC_ROOT = ENV['HOST_MUSIC_ROOT']

    def initialize
        @http = Net::HTTP.start('127.0.0.1', 4567)
    end

    def enqueue(path)
        #query = URI.encode_www_form({"cmd" => "enqueue", "path" => HOST_MUSIC_ROOT + path})
        query = URI.encode_www_form({"cmd" => "enqueue", "path" => path})
        rsp = @http.get(ROOT_QUERY + query)
        puts rsp.body
    end

    def simple_command(cmd)
        query = URI.encode_www_form({"cmd" => cmd})
        rsp = @http.get(ROOT_QUERY + query)
        #puts "simple_command: " + rsp.body
        rsp.body
    end

    def testhoge
        "testhoge"
    end
end

#pcmd = PlayCommand::new
=begin
items = [
    "01. Scarlet Faith.mp3",
    "02. white recollection.mp3",
    "03. Moon Tiare.mp3"]
items.each do |itm|
    pcmd.enqueue("Gift/Scarlet Faith/MP3/" + itm)
end
=end
#pcmd.simple_command('play')
#pcmd.simple_command('playlist')
#pcmd.simple_command('is_playing')
#pcmd.simple_command('volup 2')
#pcmd.simple_command('voldown 1')
#pcmd.simple_command('pause')
#pcmd.simple_command('clear')
#pcmd.simple_command('quit')
