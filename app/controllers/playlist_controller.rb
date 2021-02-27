# coding: utf-8

class PlaylistController < ApplicationController
    layout "jewelcase"
    def View
        render :layout => "jewelcase",
               :locals => {
                   :albuminfos => Albuminfo.all.order("genre DESC").order("album_name ASC")
               }
    end
end
