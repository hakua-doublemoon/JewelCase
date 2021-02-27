require "#{Rails.root}/app/models/MusicFile.rb"

class Album
    def initialize(album, artist, genre, path, is_flac)
        @album = album
        if  is_flac  then
            inner_path = path.gsub(MusicFile::HOST_MUSIC_ROOT, MusicFile::MUSIC_ROOT)
            @artist = MusicFile::album_artist(inner_path, artist, true)
        else
            inner_path = path.gsub(MusicFile::HOST_MUSIC_ROOT, MusicFile::MUSIC_ROOT)
            @artist = MusicFile::album_artist(inner_path, artist, false)
        end
        @genre = genre
        @tracks = []
    end
    attr_reader :album, :artist, :genre, :tracks

    def add(track_no, track_path)
        @tracks << {:track_no => track_no, :track_path => track_path}
    end

    def is_same(album, artist)
        #@self[:album] == album  &&  @self[:artist] == artist
        @album == album
    end

    def show
        puts "----"
        puts @album
        puts @artist
        puts @genre
        puts @tracks
    end

    def tracks_sort
        existsZero = false
        @tracks.each do |trk|
            if  trk[:track_no] == 0  then
                existsZero = true
                break
            end
        end
        if  not existsZero  then
            @tracks.sort! { |ta, tb| ta[:track_no] <=> tb[:track_no] }
        else
            @tracks.each.with_index do |trk, idx|
                trk[:track_no] = idx+1
            end
        end
    end
end

class PlayListCreator
    def initialize
        @music_file = MusicFile::new
    end

    def split_into_albums(albums, tag_list, is_flac)
        album_idx = 0
        tag_list.each do |tag|
            if  albums[album_idx].is_same(tag[:album], tag[:artist])  then
                albums[album_idx].add(tag[:track_no], tag[:path])
            else
                album_idx = -1
                albums.each.with_index do |alb, idx|
                    if  alb.is_same(tag[:album], tag[:artist])  then
                        album_idx = idx
                        break
                    end
                end
                if  album_idx == -1  then
                    albums << Album::new(tag[:album], tag[:artist], tag[:genre], tag[:path], is_flac)
                    album_idx = albums.length - 1
                end
                albums[album_idx].add(tag[:track_no], tag[:path])
            end
        end
    end

    def list_create(is_flac)
        flac_dirs = []
        @music_file.search(MusicFile::MUSIC_ROOT, is_flac, flac_dirs)
        #puts flac_dirs

        limit = 0
        flac_dirs.each do |fldr|
            #break if limit > 30
            limit += 1

            tag_list = []
            @music_file.tags(fldr, tag_list, is_flac)
            if  tag_list.length == 0  then
                puts fldr
                next
            end
            #p tag_list
            
            album_name = tag_list[0][:album]
            if  album_name == ""  ||  album_name.nil?  ||  album_name.blank?  then
                album_name = "\(" + fldr.split("\/")[-1] + "\)"
                tag_list[0][:album] = album_name
            end
            
            first_path = tag_list[0][:path]
            albums = [Album::new(tag_list[0][:album], tag_list[0][:artist], tag_list[0][:genre], first_path, is_flac)]
            split_into_albums(albums, tag_list, is_flac)
            pict_info = @music_file.picture_extract(first_path.gsub(MusicFile::HOST_MUSIC_ROOT, MusicFile::MUSIC_ROOT), is_flac)
            picture_id = 0
            ext = ""
            if  pict_info[0] != 0  then
                picture_id = pict_info[0]
                ext = pict_info[1]
                puts picture_id
            end
            #puts fldr

            albums.each do |alb|
                alb.tracks_sort

                begin
                    record = Albuminfo.find_by(:album_name => alb.album, :album_artist => alb.artist)
                    if  record.nil?  then
                        record = Albuminfo.create(
                            album_name: alb.album,
                            album_artist: alb.artist,
                            genre: alb.genre,
                            picture_id: picture_id,
                            pict_ext: ext,
                            tracks: [],
                            num_of_tracks: 0
                        )
                    end
                    alb.tracks.each do |trk|
                        record.tracks << trk[:track_path]
                        record.num_of_tracks = trk[:track_no]
                    end
                    record.save
                rescue => e
                    p e
                end
            end
        end #flac_dir
    end
end

creator = PlayListCreator::new
creator.list_create(true)
creator.list_create(false)
