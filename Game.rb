#! ruby -Ku

require_relative 'Card'
require_relative 'Player'

class Dice
  DICE_PIPS_1 = 1
  DICE_PIPS_2 = 2
  DICE_PIPS_3 = 3
  DICE_PIPS_4 = 4
  DICE_PIPS_5 = 5
  DICE_PIPS_6 = 6
  
  def initialize()
    @active_dice = []
    @fixed_dice = []
  end
  
  def reset()
    @active_dice = []
    @fixed_dice = []
  end
  
  def num()
    return @active_dice.length + @fix_dice.length
  end
  
  def active_num()
    return @active_dice.length
  end
  
  def fix_num()
    return @fixed_dice.length
  end
  
  def add(pips)
    # 新規にアクティブダイスを追加する
    if (Dice::DICE_PIPS_1 <= pips) and (pips <= Dice::DICE_PIPS_6)
        @active_dice.push(pips)
      return true
    else
      return false
    end
  end
  
  def change(dice_index, pips)
    # アクティブダイスの出目を変更する
    if (Dice::DICE_PIPS_1 <= pips) and (pips <= Dice::DICE_PIPS_6)
        @active_dice[dice_index] = pips
      return true
    else
      return false
    end
  end
  
  def throwActive()
  end
  
  def throwActiveAt(dice_index)
    if dice_index < @active_dice.length
      @active_dice[dice_index] = DICE_PIPS_6    # 仮に6に置き換える
      return true
    else
      return false
    end
  end
  
  def fix(dice_index)
    if dice_index < @active_dice.length
      @fixed_dice.push(@active_dice[dice_index])
      @active_dice.delete_at(dice_index)
      return true
    else
      return false
    end
  end
  
  def active_dice_pips(dice_index = nil)
    if dice_index != nil
      return @active_dice[dice_index]
    else
      return @active_dice
    end
  end
  
  def fixed_dice_pips()
    return @fixed_dice
  end
end

class Stock
  INITIAL_CARD_NUM = 
  [
    # 0, I, II, III, IV, V
    [ 5, 2,  1,   1,  1, 1], # 2 player
    [ 5, 2,  2,   2,  2, 1], # 3 player
    [ 5, 3,  3,   2,  2, 1], # 4 player
    [ 5, 4,  3,   3,  3, 1]  # 5 player
  ]
  def initialize()
    @stock = Array.new(Card::TYPE_NUM)
  end
  
  def setup(player_num)
    card_num_index = player_num - 2
    @stock[Card::CLOWN]         = Stock::INITIAL_CARD_NUM[card_num_index][0]
    @stock[Card::FAKER]         = 0
    @stock[Card::FARMER]        = Stock::INITIAL_CARD_NUM[card_num_index][1]
    @stock[Card::HOUSEMAID]     = Stock::INITIAL_CARD_NUM[card_num_index][1]
    @stock[Card::PHILOSOPHER]   = Stock::INITIAL_CARD_NUM[card_num_index][1]
    @stock[Card::CRAFTSMAN]     = Stock::INITIAL_CARD_NUM[card_num_index][1]
    @stock[Card::GUARD]         = Stock::INITIAL_CARD_NUM[card_num_index][1]
    @stock[Card::HUNTER]        = Stock::INITIAL_CARD_NUM[card_num_index][2]
    @stock[Card::ASTRONOMICAL]  = Stock::INITIAL_CARD_NUM[card_num_index][2]
    @stock[Card::MERCHANT]      = Stock::INITIAL_CARD_NUM[card_num_index][2]
    @stock[Card::GRANDE_DAME]   = Stock::INITIAL_CARD_NUM[card_num_index][3]
    @stock[Card::PAWNSHOP]      = Stock::INITIAL_CARD_NUM[card_num_index][3]
    @stock[Card::KNIGHT]        = Stock::INITIAL_CARD_NUM[card_num_index][3]
    @stock[Card::MAGICIAN]      = Stock::INITIAL_CARD_NUM[card_num_index][3]
    @stock[Card::ALCHEMIST]     = Stock::INITIAL_CARD_NUM[card_num_index][4]
    @stock[Card::BISIHOP]       = Stock::INITIAL_CARD_NUM[card_num_index][4]
    @stock[Card::NOBLE]         = Stock::INITIAL_CARD_NUM[card_num_index][4]
    @stock[Card::GEENERAL]      = Stock::INITIAL_CARD_NUM[card_num_index][4]
    @stock[Card::QUEEN]         = Stock::INITIAL_CARD_NUM[card_num_index][5]
    @stock[Card::KING]          = Stock::INITIAL_CARD_NUM[card_num_index][5]
  end
  
  def draw(card_index)
    if @stock[card_index] > 0
      @stock[card_index] -= 1
      return Card.new(card_index)
    else
      return nil
    end
  end
  
  def draw?(card_index, dice)
    # 残り枚数がなければ常に取れない
    if @stock[card_index] == 0
      return false
    end
    
    # 取得条件を満たせば取れる
    # 今のところ常に取れることにする
    return true
  end
  
  def existKing?()
    # 国王が獲得済みならtrue
    if @stock[Card::KING] == 0
      return true
    else
      return false
    end
  end
  
  def card_index_name_list()
    # デバッグ用
    array = []
    cnt = 0
    @stock.each_with_index{|card_num, card_index|
      if card_num != 0
        array.push("#{card_index.to_s}:#{Card::CARD_SHROT_NAME[card_index]}:#{card_num}")
      end
      cnt += 1
    }
    return array
  end
end

class TurnOfPlayer
  NOT_EDGE = 0
  EDGE = 1
  def initialize()
    @now_player_index = 0
    @clockwise        = true
    @player_num       = 0
    @round            = 0
  end
  
  attr_reader   :round
  attr_reader   :now_player_index
  attr_reader   :player_num
  
  def setup(player_num)
    @player_num = player_num
  end
  
  def next()
    if (@clockwise == true) and (@now_player_index == @player_num-1)
      # 端の場合は向きの反転のみ
      @clockwise = false
      # ラウンドを次に進める
      @round += 1
      return TurnOfPlayer::EDGE
    elsif (@clockwise == false) and (@now_player_index == 0)
      # 端の場合は向きの反転のみ
      @clockwise = true
      # ラウンドを次に進める
      @round += 1
      return TurnOfPlayer::EDGE
    else
      # 端でない場合はインデックスのみ
      if @clockwise
        @now_player_index += 1
      else
        @now_player_index -= 1
      end
      return TurnOfPlayer::NOT_EDGE
    end
  end
end

class OrderOfPlayer
  def initialize()
    @normal_order = []
    @final_order = []
  end
  
  attr_reader   :normal_order
  attr_reader   :final_order
  
  def set_normal_order(orders)
    @normal_order = orders.clone
  end
  
  def set_final_order(orders)
    @final_order = @normal_order.clone
  end
end

class Game
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5
  
  MIN_PLAYERS_INDEX = 0
  MAX_PLAYERS_INDEX = 4
  INVALID_PLAYER_INDEX = 255
  
  def initialize()
    @stock = Stock.new
    @dice = Dice.new
    @players = [nil, nil, nil, nil, nil]
    @order = OrderOfPlayer.new
    @turn = TurnOfPlayer.new
    @final_round = false
    @end_of_game = false
  end
  
  def start()
    @stock.setup(player_num())
    @turn.setup(player_num())
    # プレイ順は仮にここで決める、自由に決定できるようにしたい
    @order.set_normal_order(Array(0..(player_num()-1)))
  end
  
  def join(player, player_index)
    if MIN_PLAYERS_INDEX <= player_index and player_index <= MAX_PLAYERS_INDEX
      @players[player_index] = player
      return true
    else
      return false
    end
  end
  
  def player_num()
    num = 0
    
    @players.each {|player|
      if player != nil
        num += 1
      end
    }
    
    return num
  end
  
  def end_of_game?()
    return @end_of_game
  end
  
  def final_round?()
    return @final_round
  end
  
  def turn_end()
    # 次のプレイヤーのターンにする
    round = @turn.next()

    # 状態遷移
    if !final_round? and @stock.existKing? == true and round == TurnOfPlayer::EDGE
      # 最終ラウンドではない and 国王がとられている and ラウンドの最後 なら最終ラウンドにする
      shift_final_round()
    elsif final_round? and round == TurnOfPlayer::EDGE
      # 最終ラウンドである and ラウンドの最後 ならゲーム終了にする
      shift_game_end()
    end
  end
  
  def dice()
    return @dice
  end
  
  def stock()
    return @stock
  end
  
  def now_player()
    return @players[@turn.now_player_index]
  end
  
  def now_player_index()
    return @turn.now_player_index
  end

  def winner()
    @players.each_with_index { |player, index|
      if player != nil and player.have_king?
        return index
      end
    }
    return INVALID_PLAYER_INDEX
  end
  
  def round()
    return @turn.round
  end

  private
  def shift_final_round()
    @final_round = true
  end

  def shift_game_end()
    @end_of_game = true
  end
end

