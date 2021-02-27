// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .
//= require jquery
//= require jquery_ujs

var g_albumview = ""

function pl_ent_click(event)
{
    var target = event.target
    var infos = undefined
    //console.log(event)
    if (target.className != "playlist-entry") {
        infos = event.target.parentElement.childNodes
    } else {
        infos = event.target.childNodes        
    }

    var album = {}
    //console.log(infos)
    Array.from(infos).forEach( (child) => {
        switch (child.className) {
            case "album-name":
                album["name"] = child.innerText
                break
            case "album-artist":
                album["artist"] = child.innerText
                break
            default:
                break
        }
    })

    console.log("album: " + JSON.stringify(album))

    $.ajax('ajax/ViewTracks', {
        type: 'post',
        data: album,
        dataType: 'html'
    }).done( (rsp) => {
        //console.log("response: " + JSON.stringify(rsp))

        g_albumview = $("#main-view").html()
        localStorage.last_position = window.pageYOffset
        $.when(
            $("#main-view").html(rsp)
        ).done ( () => {
            register_track_view_event(),
            window.scroll(0, 0)
        })
        //$("#main-view").html(albumview)
        //console.log(albumview)

    }).fail( (obj, ts, err) => {
        console.log("e-rsp: " + err)
    })
}

function register_album_view_event()
{
    var pl_ents = document.getElementsByClassName("playlist-entry")
    //console.log(pl_ents[0].style.background = )
    Array.from(pl_ents).forEach( (element) => {
        element.addEventListener("click", pl_ent_click, {}, false)
        //element.style.background = "#FFF"
    })
}

function after_register_album_view_event()
{
    var pl_ents = document.getElementsByClassName("playlist-entry")

    $.when(
        //console.log(pl_ents[0].style.background = )
        Array.from(pl_ents).forEach( (element) => {
            //element.addEventListener("click", pl_ent_click, {}, false)
            element.style.background = "#FFF"
        })
    ).done()
}

function track_click(event)
{
    var target = event.target
    var track_elm = undefined
    //console.log(event)
    if (target.className != "track-entry") {
        track_elm = event.target.parentElement
    } else {
        track_elm = event.target
    }

    //console.log(track_elm.attributes)
    var track_path = track_elm.getAttribute('fpath')
    console.log("req play : " + track_path)

    $.ajax('ajax/play', {
        type: 'post',
        data: {
                "cmd": "enqueue",
                "tracks": [track_path]
            },
        dataType: 'html'
    }).done( (rsp) => {
        console.log("enq: " + rsp)
    }).fail( (obj, ts, err) => {
        console.log("enq-rsp: " + err)
    })
}

function play_button_event(cmd)
{
    $.ajax('ajax/play', {
        type: 'post',
        data: {
                "cmd": cmd
            },
        dataType: 'html'
    }).done( (rsp) => {
        console.log("cmd: " + cmd + " / " + rsp)
    }).fail( (obj, ts, err) => {
        console.log("cmd-rsp: " + err)
    })
}

function register_track_view_event()
{
    var btn = document.getElementsByClassName("play-back")
    btn[0].addEventListener("click", () => 
        $.when(
            $("#main-view").html(g_albumview)
        ).done ( () => {
            console.log('last position [R] : ' + localStorage.last_position)
            window.scroll(0, localStorage.last_position)
            register_album_view_event()
        })
    , {}, false)

    btn = document.getElementsByClassName("play-button")
    btn[0].addEventListener("click", () => { play_button_event("play") } , {}, false)
    btn = document.getElementsByClassName("play-stop")
    btn[0].addEventListener("click", () => { play_button_event("clear") } , {}, false)
    btn = document.getElementsByClassName("play-vol-down")
    btn[0].addEventListener("click", () => { play_button_event("voldown 1") } , {}, false)
    btn = document.getElementsByClassName("play-vol-up")
    btn[0].addEventListener("click", () => { play_button_event("volup 1") } , {}, false)

    var trks = document.getElementsByClassName("track-entry")
    Array.from(trks).forEach( (element) => {
        element.addEventListener("click", track_click, {}, false)
    })

    $.ajax('ajax/status', {
        type: 'get',
        dataType: 'json'
    }).done( (rsp) => {
        console.log("status: " + JSON.stringify(rsp))
        if (rsp.is_playing == "0") {
            play_button_event("clear")
        }
    }).fail( (obj, ts, err) => {
        console.log("status: " + err)
    })
}

window.onload = (event) => {
    console.log('page is fully loaded')

    $.when(
        register_album_view_event()
    ).done(
        console.log('last position : ' + localStorage.last_position),
        window.scroll(0, localStorage.last_position),
        //after_register_album_view_event()
    )
}
