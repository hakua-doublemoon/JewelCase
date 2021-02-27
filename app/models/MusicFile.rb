require 'taglib'
require 'openssl'


class MusicFile
    MUSIC_ROOT = ENV['MUSIC_ROOT']
    HOST_MUSIC_ROOT = ENV['HOST_MUSIC_ROOT']
    JACKET_PATH = ENV['JACKET_PATH']
    
    def initialize
    end

    def self.album_artist(fpath, artist, is_flac)
        ret = "\(#{artist}\)"
        if  is_flac  then
            TagLib::FLAC::File.open(fpath) do |flac|
                return ret if not flac.xiph_comment?
                fl = flac.xiph_comment.field_list_map
                aa = fl["ALBUMARTIST"]
                if  !aa.nil?  &&  aa.length > 0  &&  !aa[0].empty?  then
                    ret = aa[0]
                end
            end
            puts "ALBUMARTIST=" + ret
        else
            #puts "ID3::album_artist < " + fpath
            TagLib::MPEG::File.open(fpath) do |mpeg|
                return ret if mpeg.id3v1_tag?
                return ret if not mpeg.id3v2_tag?

                tag = mpeg.id3v2_tag
                #p tag.frame_list.each {|l| puts l.to_string}
                #p tag.frame_list("TPE2").each {|l| puts l.to_string}
                tpe2 = tag.frame_list("TPE2")
                if  tpe2.length > 0  &&  !tpe2[0].to_string.empty?  then
                    ret = tpe2[0].to_string
                end
            end
            puts "TPE2=" + ret
        end
        ret
    end

    def flac_tag(fpath)
        #puts fpath
        ret = nil
        TagLib::FLAC::File.open(fpath) do |flac|
            tag = flac.tag
            ret = {
                :album => tag.album,
                :artist => tag.artist,
                :genre => tag.genre,
                :track_no => tag.track,
                :path => fpath.gsub(MUSIC_ROOT, HOST_MUSIC_ROOT),
                :title => tag.title,
            }
        end
        ret
    end

    def mp3_tag(fpath)
        #bin_file = File.open(fpath, "rb")
        #bin_tag = bin_file.read(3).unpack("a*")
        #puts fpath
        ret = nil
        TagLib::MPEG::File.open(fpath) { |mpeg|
            if  mpeg.id3v1_tag?  then
                tag = mpeg.id3v1_tag
                ret = {
                    :album => tag.album,
                    :artist => tag.artist,
                    :genre => tag.genre,
                    :track_no => tag.track,
                    :path => fpath.gsub(MUSIC_ROOT, HOST_MUSIC_ROOT),
                    :title => tag.title,
                }
            elsif  mpeg.id3v2_tag?  then
                tag = mpeg.id3v2_tag
                ret = {
                    :album => tag.album,
                    :artist => tag.artist,
                    :genre => tag.genre,
                    :track_no => tag.track,
                    :path => fpath.gsub(MUSIC_ROOT, HOST_MUSIC_ROOT),
                    :title => tag.title,
                }
                #p "tag.title " + tag.title
            else
                puts "unknown tag : " + fpath
                ret = {
                    :album => "",
                    :artist => "",
                    :genre => "",
                    :track_no => "",
                    :path => fpath.gsub(MUSIC_ROOT, HOST_MUSIC_ROOT),
                    :title => "",
                }
            end
        }
        ret
    end

    def search(path, is_flac, dirs)
        has_find = false
        Dir.glob(path + '*') do |item|
            if  FileTest.directory?(item)  then
                search(item + '/', is_flac, dirs)
            else
                next if has_find
                if  is_flac  &&  item[-4, 4] == "flac"  then
                    has_find = true
                    dirs << path.gsub(/\/.*flac$/, "\/")
                elsif  !is_flac  &&  item[-3, 3] == "mp3"  then
                    has_find = true
                    #puts item
                    dirs << path.gsub(/\/.*mp3$/, "\/")
                else
                    #
                end
            end
        end
    end

    def tags(path, tlist, is_flac)
        #puts path
        Dir.glob(path + '*') do |item|
            if  not FileTest.directory?(item)  then
                if  is_flac  &&  item[-4, 4] == "flac"  then
                    tlist << flac_tag(item)
                elsif  !is_flac  &&  item[-3, 3] == "mp3"  then
                    tlist << mp3_tag(item)
                else
                    #puts "unexpected path : " + item
                end
            end
        end
    end

    def picture_extract(fpath, is_flac)
        #p fpath
        ret = [0]
        if  is_flac  then
            TagLib::FLAC::File.open(fpath) { |flac|
                pics = flac.picture_list
                if  pics.length > 0  then
                    pic = pics[0]
                    name_hash = OpenSSL::Digest::SHA256.digest(fpath).unpack("I*")
                    name = (name_hash[0] >> 1).to_s
                    ext = ""
                    #p name
                    case pic.mime_type
                    when /.*png/
                        IO::binwrite(JACKET_PATH + name + ".png", pic.data)
                        ext = '.png'
                    when /.*jpeg/, /.*jpg/
                        IO::binwrite(JACKET_PATH + name + ".jpeg", pic.data)
                        ext = '.jpeg'
                    when /.*bmp/
                        IO::binwrite(JACKET_PATH + name + ".bmp", pic.data)
                        ext = '.bmp'
                    else
                        puts "mine: " + pic.mime_type
                        return [0]
                    end
                    ret = [name.to_i, ext]
                end
            }
        else
            TagLib::MPEG::File.open(fpath) { |mpeg|
                return ret if mpeg.id3v1_tag?
                return ret if not mpeg.id3v2_tag?

                tag = mpeg.id3v2_tag
                pics = tag.frame_list('APIC')
                if  pics.length > 0  then
                    pic = pics[0]
                    name_hash = OpenSSL::Digest::SHA256.digest(fpath).unpack("I*")
                    name = (name_hash[0] >> 1).to_s
                    ext = ""
                    #p name
                    case pic.mime_type
                    when /.*png/
                        IO::binwrite(JACKET_PATH + name + ".png", pic.picture)
                        ext = '.png'
                    when /.*jpeg/, /.*jpg/
                        IO::binwrite(JACKET_PATH + name + ".jpeg", pic.picture)
                        ext = '.jpeg'
                    when /.*bmp/
                        IO::binwrite(JACKET_PATH + name + ".bmp", pic.picture)
                        ext = '.bmp'
                    else
                        puts "mine: " + pic.mime_type
                        return [0]
                    end
                    ret = [name.to_i, ext]
                end
            }
        end
        ret
    end
end

#mf = MusicFile::new
#p mf.flac_tag('/var/music/La_Prumiere/Galaxy Triangle/01. La priere - div a3.flac')
#p MusicFile::album_artist('/var/music/La_Prumiere/Galaxy Triangle/01. La priere - div a3.flac', 'dummy', true)
#p mf.mp3_tag('/var/music/0_mora/Various Artists/Veiled/002-Raindrop.mp3')
#p MusicFile::album_artist('/var/music/0_mora/Various Artists/Veiled/002-Raindrop.mp3', "dummy")
#mf.current_layer(MusicFile::MUSIC_ROOT)
#mf.picture_extract('/var/music/BouQuet/うたう少女のグリザイユ/00-01-はじまりの花音.flac')
