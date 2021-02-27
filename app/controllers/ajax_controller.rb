# coding: utf-8
require 'json'

require "#{Rails.root}/app/models/MusicFile.rb"
require "#{Rails.root}/app/models/PlayCommand.rb"


class AjaxController < ApplicationController
    layout "ajax"

    @dbg = "null"
    @music_file = nil
    @pcmd = nil

    private
    def tracks_get(album_name, album_artist)
        tracks = []
        jacket_name = ""

        begin
            album = Albuminfo.find_by(:album_name => album_name, :album_artist => album_artist)
            album.tracks.each do |trk|
                if  trk[-4, 4] == "flac"  then
                    tag = @music_file.flac_tag(trk.gsub(MusicFile::HOST_MUSIC_ROOT, MusicFile::MUSIC_ROOT))
                    tracks << {
                        :number => tag[:track_no], 
                        :artist => tag[:artist], 
                        :title => tag[:title], 
                        :file => trk,
                    }
                else
                    tag = @music_file.mp3_tag(trk.gsub(MusicFile::HOST_MUSIC_ROOT, MusicFile::MUSIC_ROOT))
                    tracks << {
                        :number => tag[:track_no], 
                        :artist => tag[:artist], 
                        :title => tag[:title], 
                        :file => trk,
                    }
                end
            end
            jacket_name = album.picture_id.to_s + album.pict_ext  if  album.picture_id != 0
            @dbg = "dbg " + album.tracks[0]
            tracks.sort! {|a,b| a[:number] <=> b[:number]}
            #@dbg = "dbg: " + tracks[1][:number].to_s
        rescue => e
            @dbg = e.to_s #Albuminfo.where(:album_name => album_name, :album_artist => album_artist).to_sql
        end

        [tracks, jacket_name]
    end

    public
    def ViewTracks
        if  @music_file.nil?  then
            @music_file = MusicFile::new
        end

        album_name = params[:name]
        album_artist = params[:artist]
        track_info = tracks_get(album_name, album_artist)
        tracks = track_info[0]
        layout = "ajax"

        if  album_name.nil?  then
            tracks = [
                {:number =>  1, :artist => "星名優子", :title => "カボチャの国のアリス", :genre => "dummy"},
                {:number => 10, :artist => "葉月ゆら", :title => "薄羽陽炎", :genre => "dummy"}
            ]
            layout = "jewelcase"
        end

        render :layout => layout,
              #:content_type => "application/json",
               :locals => {
                   :debug_info => @dbg,
                   :tracklist => tracks,
                   :jacket_name => track_info[1],
               }
    end

    def play
        if  @pcmd.nil?  then
            @pcmd = PlayCommand::new
        end

        res = ""
        case params[:cmd]
        when 'enqueue'
            res = URI.decode_www_form_component(params[:tracks][0])
            begin
                params[:tracks].each do |trk|
                    @pcmd.enqueue(URI.decode_www_form_component(trk))
                end
            rescue => e
                #res = URI.decode_www_form(params[:tracks][0])[0]
                res = e.to_s
            end
        when 'play', 'clear', /voldown \d/, /volup \d/ 
            @pcmd.simple_command(params[:cmd])
        else
        end

        render :layout => "ajax",
               :locals => {
                   :debug_info => res
               }
    end

    def status
        is_playing = ""

        if  @pcmd.nil?  then
            @pcmd = PlayCommand::new
        end

        out = @pcmd.simple_command('is_playing').split(/\n|\r|\e/)
        out.each do |ln|
            next if  ln.include?('is_playing')
            next if  ln == ""
            is_playing = ln
            break
        end

        #is_playing = "2"
        hash = { :is_playing => is_playing}

        render :layout => "ajax",
               :content_type => "application/json",
               :status => 200,
               :locals => {
                   :status_json => JSON.dump(hash)
               }
    end
end
