gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local video
local url
local next_try = 0
local audio = true

local function stop_and_wait(t)
    if video then
        video:dispose()
        video = nil
    end
    next_try = sys.now() + t
end

local function maybe_restart()
    if url == "" then
        return
    end
    if sys.now() < next_try then
        return
    end
    video = resource.load_video{
        file = url,
        raw = true,
        audio = audio,
    }
end

util.json_watch("config.json", function(config)
    url = config.url
    audio = config.audio
    next_try = sys.now()
    stop_and_wait(0)
end)

function node.render()
    gl.clear(0, 0, 0, 1)

    if video then
        local state, w, h = video:state()
        if state == "loaded" then
            local x1, y1, x2, y2 = util.scale_into(NATIVE_WIDTH, NATIVE_HEIGHT, w, h)
            video:place(x1, y1, x2, y2):layer(2)
        elseif state == "finished" or state == "error" then
            stop_and_wait(10)
        end
    else
        maybe_restart()
    end
end
