class CreateAlbuminfos < ActiveRecord::Migration[5.2]

    def change
      create_table :albuminfos do |t|
        t.text :album_name
        t.text :album_artist
        t.text :genre
        t.integer :picture_id
        t.string :pict_ext, limit: 6
        t.text :tracks, array: true
        t.integer :num_of_tracks
  
        t.timestamps
      end
    end

end
