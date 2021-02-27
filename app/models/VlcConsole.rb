require 'bundler/setup'
Bundler.require
require 'net/ssh'
require 'net/ssh/cli'

#require "./MusicFile.rb"
require "/myapp/app/models/MusicFile.rb"


class VlcConsole
    def initialize
        vlc_user = ENV['VLC_USER']
        vlc_user_passwd = ENV['VLC_USER_PASSWORD']

        @session = Net::SSH.start('172.18.0.1', vlc_user, password: vlc_user_passwd)
        @cli = @session.cli(default_prompt: />|#{vlc_user}/)
        puts @cli.cmd("cd #{MusicFile::HOST_MUSIC_ROOT}")
        sleep 1
        puts @cli.cmd("vlc --equalizer-bands \"3 2 1 0 1 2 3 4 5\" --equalizer-preamp 0")
        puts @cli.cmd("help")
    end

    def enqueue(dpath)
        @cli.cmd("enqueue " + dpath.gsub(MusicFile::HOST_MUSIC_ROOT, ""))
    end

    def simple_command(cmd)
        @cli.cmd(cmd)
    end

    def sync_command(cmd)
        puts cmd
        @cli.write(cmd + "\n")
        2.times do
            sleep 0.2
            puts @cli.read
        end
    end
end
