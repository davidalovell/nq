-- Vox lib
local Vox = {}
function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on = args.on == nil and true or args.on
  o.level = args.level == nil and 1 or args.level
  o.scale = args.scale == nil and {0,2,4,6,7,9,11} or args.scale
  o.transpose = args.transpose == nil and 0 or args.transpose
  o.degree = args.degree == nil and 1 or args.degree
  o.octave = args.octave == nil and 0 or args.octave
  o.synth = args.synth == nil and function(note, level) return note, level end or args.synth
  o.wrap = args.wrap ~= nil and args.wrap or false
  o.mask = args.mask
  o.negharm = args.negharm ~= nil and args.negharm or false

  -- TODO
  -- o.length = args.length == nil and 1/8 or args.length

  o.vox = args.vox == nil and {} or args.vox
  o.clk = args.clk == nil and {} or args.clk
  o.action = args.action == nil and {} or args.action

  return o
end

function Vox:play(args)
  local args = args == nil and {} or self.update(args)
  local on, level, scale, transpose, degree, octave, synth, mask, wrap, negharm, ix, val, note

  on = self.on and (args.on == nil and true or args.on)
  level = self.level * (args.level == nil and 1 or args.level)
  scale = args.scale == nil and self.scale or args.scale
  transpose = self.transpose + (args.transpose == nil and 0 or args.transpose)
  degree = (self.degree - 1) + ((args.degree == nil and 1 or args.degree) - 1)
  octave = self.octave + (args.octave == nil and 0 or args.octave)
  synth = args.synth == nil and self.synth or args.synth
  wrap = args.wrap == nil and self.wrap or args.wrap
  mask = args.mask == nil and self.mask or args.mask
  negharm = args.negharm == nil and self.negharm or args.negharm

  octave = wrap and octave or octave + math.floor(degree / #scale)
  ix = mask and self.apply_mask(degree, scale, mask) % #scale + 1 or degree % #scale + 1
  val = negharm and (7 - scale[ix]) % 12 or scale[ix]
  note = val + transpose + (octave * 12)

  return on and synth(note, level)--, length)
end

function Vox.update(data)
  local updated = {}
  for k, v in pairs(data) do
    updated[k] = type(v) == 'function' and data[k]() or data[k]
  end
  return updated
end

function Vox.apply_mask(degree, scale, mask)
  local ix, closest_val = degree % #scale + 1, mask[1]
  for _, val in ipairs(mask) do
    val = (val - 1) % #scale + 1
    closest_val = math.abs(val - ix) < math.abs(closest_val - ix) and val or closest_val
  end
  local degree = closest_val - 1
  return degree
end

function Vox:newseq(args)
  local args = args == nil and {} or args
  self.addseq = function(self, args)
    self.seq.dyn = self.seq.dyn == nil and {} or self.seq.dyn
    for k, v in pairs(args) do
      self['seq'][k] = v
      self['seq']['dyn'][k] = (type(v) == 'function' or type(v) == 'table') and function() return v() end or v
    end
  end

  -- self.seq.sync = function()
  --   return
  --     self.seq.sync() *
  --     self.seq.division *
  --     all.division *
  -- end

  self:addseq(args)
end

-- helper functions
function Vset(objects, property, val)
  for k, v in pairs(objects) do
    v[property] = val
  end
end

function Vdo(objects, method, args)
  for k, v in pairs(objects) do
    v[method](v, args)
  end
end

return Vox
