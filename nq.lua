-- quant midi
-- idea:
-- use digitone as a sequencer
-- send it to norns for quantising and scale management
-- send it back



engine.name = 'PolyPerc'
MusicUtil = require 'musicutil'
m = midi.connect()
s = require 'sequins'

function scale(scale_type, transpose)
  return MusicUtil.generate_scale_of_length(0, scale_type, 127)
end

function snap(note_num, snap_array)
  return MusicUtil.snap_note_to_array(note_num, snap_array)
end

m.event = function(data)
  local msg = midi.to_msg(data)
  msg.note = snap(msg.note, scale('lydian'))
  local data = midi.to_data(msg)
  m:send(data)
end