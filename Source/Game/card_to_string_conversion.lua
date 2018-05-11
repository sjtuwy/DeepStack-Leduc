--- Converts between string and numeric representations of cards.
-- @module card_to_string_conversion

require "string"
require "torch"
local arguments = require 'Settings.arguments'
local  game_settings =  require 'Settings.game_settings'

local M = {};

---All possible card suits - only the first 2 are used in Leduc Hold'em.
M.suit_table = {'h', 's', 'c', 'd'}

---All possible card ranks - only the first 3-4 are used in Leduc Hold'em and 
-- variants.
M.rank_table = {'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'}

--- Gets the suit of a card.
-- @param card the numeric representation of the card
-- @return the index of the suit
function M:card_to_suit(card)
  return card % game_settings.suit_count + 1
end

--- Gets the rank of a card.
-- @param card the numeric representation of the card
-- @return the index of the rank
function M:card_to_rank(card)
  return torch.floor((card -1) / game_settings.suit_count ) + 1
end;

--- Holds the string representation for every possible card, indexed by its 
-- numeric representation.
M.card_to_string_table ={}
for card = 1, game_settings.card_count do 
  local rank_name = M.rank_table[M:card_to_rank(card)]
  local suit_name = M.suit_table[M:card_to_suit(card)]
  M.card_to_string_table[card] =  rank_name .. suit_name
end

--- Holds the numeric representation for every possible card, indexed by its 
-- string representation.
M.string_to_card_table = {}
for card = 1, game_settings.card_count do 
  M.string_to_card_table[M.card_to_string_table[card]] = card
end
 
--- Converts a card's numeric representation to its string representation.
-- @param card the numeric representation of a card
-- @return the string representation of the card
function M:card_to_string(card)
  assert(card > 0 and card <= game_settings.card_count )
  return M.card_to_string_table[card]
end

--- Converts several cards' numeric representations to their string 
-- representations.
-- @param cards a vector of numeric representations of cards
-- @return a string containing each card's string representation, concatenated
function M:cards_to_string(cards)
  if cards:dim() == 0 then
    return ""
  end
  
  local out = ""
  for card =1, cards:size(1) do
    out = out .. self:card_to_string(cards[card])
  end
  return out
end

--- Converts a card's string representation to its numeric representation.
-- @param card_string the string representation of a card
-- @return the numeric representation of the card
function M:string_to_card(card_string)
  local card = M.string_to_card_table[card_string]
  assert(card > 0 and card <= game_settings.card_count )
  return card
end

--- Converts a hand's string representation to its numeric representation. Only 1 or 2 holdcards supported for now
-- @param card_string the string representation of a hand
-- @return the numeric representation of the hand
function M:string_to_hand(hand_string)
    assert(string.len(hand_string) == 2 * game_settings.holecard_count)
    assert(game_settings.holecard_count == 1 or game_settings.holecard_count == 2)
    if game_settings.holecard_count == 1 then
        local card = M.string_to_card_table[hand_string]
        assert(card > 0 and card <= game_settings.card_count )
        return card
    end

    local hand_vec = {}
    for i = 1, game_settings.holecard_count do
        local card = M.string_to_card_table[string.sub(hand_string, 2 * i - 1, 2 * i)]
        assert(card > 0 and card <= game_settings.card_count )
        table.insert(hand_vec, card)
    end
    assert(hand_vec[1] ~= hand_vec[2])
    table.sort(hand_vec, function(a,b) return a > b end)
    -- (x,y) => (x-1) * (x-2)/2 + (x-y)
    local hand = (hand_vec[1] - 1) * (hand_vec[1] - 2) / 2 + (hand_vec[1] - hand_vec[2])
    assert(hand > 0 and hand <= game_settings.card_count * (game_settings.card_count - 1) / 2)
    return hand
end

--- Converts a string representing zero or one board cards to a 
-- vector of numeric representations.
-- @param card_string either the empty string or a string representation of a 
-- card
-- @return either an empty tensor or a tensor containing the numeric 
-- representation of the card
function M:string_to_board(card_string)
  assert(card_string)
  
  if card_string == '' then
    return arguments.Tensor{}
  end
  assert(string.len(card_string) % 2 == 0 and string.len(card_string) / 2 <= game_settings.board_card_count)
  local board = {} 
  for i = 1,string.len(card_string) / 2 do
      local card = self:string_to_card(string.sub(card_string, 2 * i - 1, 2 * i))
      table.insert(board, card)
  end
  local out = arguments.Tensor(board)
  assert(out:nDimension() == 1 and out:size(1) == string.len(card_string) / 2)
  return out

end

return M
