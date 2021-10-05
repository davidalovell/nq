-- quant midi
-- idea:
-- use digitone as a sequencer
-- send it to norns for quantising and scale management
-- send it back

engine.name = 'PolyPerc'
MusicUtil = require 'musicutil'
m = midi.connect()

function scale(scale_type) 
  return MusicUtil.generate_scale_of_length(0, scale_type, 127)
end

function note(note_num, snap_array)
  return MusicUtil.snap_note_to_array(note_num, snap_array)
end

userscale = scale('ionian')

function init()
end

m.event = function(data)
  local d = midi.to_msg(data)

  if d.type == 'note_on' then
    m:note_on(note(d.note, userscale), d.vel)
    m:note_on(note(d.note + 4, userscale), d.vel)
  end

  if d.type == 'note_off' then
    m:note_off(note(d.note, userscale), d.vel)
    m:note_off(note(d.note + 4, userscale), d.vel)
  end
end