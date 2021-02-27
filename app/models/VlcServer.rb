require 'sinatra'

#require './VlcConsole.rb'
require '/myapp/app/models/VlcConsole.rb'


def exit_task
    sleep 2
    Process.kill('TERM', Process.pid)
end

console = VlcConsole::new

get '/vlc' do
    puts "--get--"
    p params
    cmd = params['cmd']
    case cmd
    when 'quit'
        console.simple_command('quit')
        Thread.new {
            exit_task
        }
        "quit"
    when 'playlist', 'play', 'clear', /volup \d/, /voldown \d/, 'pause'
        console.simple_command(cmd)
    when 'is_playing', 'status'
        #puts console.sync_command(cmd)
        #"sv:hoge"
        ret = console.simple_command(cmd)
        puts ret
        ret
    when 'enqueue'
        path = params['path']
        console.enqueue(path)
        path
    else
        puts "ignore > " + cmd
    end
end

