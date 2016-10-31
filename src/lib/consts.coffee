modes = {
  9: ['skirmish']
  10: ['control']
  11: ['salvage']
  12: ['clash']
  13: ['rumble']
  14: ['trials of osiris', 'too']
  15: ['doubles']
  19: ['iron banner', 'ib']
  23: ['elimination']
  24: ['rift']
  28: ['zone control', 'zc']
  29: ['srl']
  31: ['supremacy']
  523: ['crimson doubles', 'cd']
  531: ['rumble supremacy', 'rs']
}

module.exports = {
  platforms: {
    2: 'PlayStation'
    1: 'Xbox'
  }
  modes: modes
  genders: ['Male', 'Female']
  classes: ['Titan', 'Hunter', 'Warlock']
  findMode: (mode) =>
    modeLower = mode.toLowerCase()
    for key, value of modes
      if modeLower in value || value[0].startsWith modeLower
        return [key, value[0]]
}
