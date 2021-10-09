-- quant midi
-- idea:
-- use digitone as a sequencer
-- send it to norns for quantising and scale management
-- send it back

-- norns.script.load('code/nq/nq.lua')

engine.name = 'PolyPerc'
MusicUtil = require 'musicutil'
m = midi.connect()
s = require 'sequins'
v = include 'lib/v'

function scale(scale_type, transpose)
  return MusicUtil.generate_scale_of_length(0, scale_type, 127)
end

function snap(note_num, snap_array)
  return MusicUtil.snap_note_to_array(note_num, snap_array)
end

userscale = scale('lydian')
voxscale = MusicUtil.generate_scale_of_length(60, scale_type, 127)

m.event = function(data)
  local msg = midi.to_msg(data)
  msg.note = snap(msg.note, userscale)
  local data = midi.to_data(msg)
  m:send(data)
end

m:start()

-- do_note = function(note, transpose)
--   clock.run(
--     function()
--       m:note_on(snap(nn + transpose - 1, userscale), 127, 2)
--       clock.sleep(0.1)
--       m:note_off(snap(nn + transpose - 1, userscale), 127, 2)
--     end
--   )
-- end

note = s{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
c = clock.run(
  function()
    while true do
      local nn = note()
      local transpose = 72
      m:note_on(snap(nn + transpose - 1, userscale), 127, 2)
      clock.sync(1/8)
      m:note_off(snap(nn + transpose - 1, userscale), 127, 2)
      clock.sync(1/8)
    end
  end
)

