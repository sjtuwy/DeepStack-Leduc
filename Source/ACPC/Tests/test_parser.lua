require "ACPC.protocol_to_node"
local constants = require "Settings.constants"

local protocol_to_node = ACPCProtocolToNode()
local state = protocol_to_node:parse_state("MATCHSTATE:0:99:cc/r8146:Kh|/As")

constants.streets_count = 4
print('testing ACPCProtocolToNode._parse_state case 1...')
local parsed_state = protocol_to_node:_parse_state("MATCHSTATE:0:99:cc/r8146c/cc/cc:KhTs|/AsKsQh/2d/3h")
print('testing ACPCProtocolToNode._parse_state case 2...')
local parsed_state = protocol_to_node:_parse_state("MATCHSTATE:0:99:cc/r8146c/cc:KhTs|/AsKsQh/2d")
constants.streets_count = 2

local debug = 0
