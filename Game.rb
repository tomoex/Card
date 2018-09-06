#! ruby -Ku

require_relative 'Card'
require_relative 'Player'

class Dice
  # ゲームで利用するダイスのセット(つまり複数のダイスの組を意味する)
  #
  # このクラスは下記で定義するダイスのふるまいと、ダイスのセットに含まれるダイスの目を参照する機能を提供する。
  #
  # - ダイスのセットは0個以上の任意個のダイスの集合である
  # - ダイスのセットの初期状態でのダイスの個数は0個である
  # - ダイスのセットにはダイスを追加することができる
  # - ダイスのセットを初期状態に戻す以外の方法で追加したダイスを減らすことはできない
  #
  # - ダイスは6面ダイスである
  # - ダイスは2種類の状態のいずれかに属する
  #     - アクティブダイス
  #     - 確定ダイス
  # - ダイスのセットにダイスを加えたとき、そのダイスはアクティブダイスとなる
  # - アクティブダイスは
  #     - 振ることができる(ランダムな目に変えることができる)
  #     - 任意の目に変更することができる
  #     - 確定ダイスにすることができる
  # - 確定ダイスは
  #     - 目の変更をすることができない

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
    # ダイスのセットを初期状態(ダイスがない)に戻す
    @active_dice = []
    @fixed_dice = []
  end
  
  def num()
    # ダイスのセットに含まれるすべてのダイスの数
    return @active_dice.length + @fix_dice.length
  end
  
  def active_num()
    # ダイスのセットに含まれるアクティブダイスの数
    return @active_dice.length
  end
  
  def fix_num()
    # ダイスのセットに含まれる固定ダイスの数
    return @fixed_dice.length
  end
  
  def add(pips = Dice::DICE_PIPS_1)
    # 新規ダイスを追加する(アクティブダイスを追加する)
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
    # アクティブダイスをすべて振りなおす
    (0..(self.active_num-1)).each{ |dice_index|
      throwActiveAt(dice_index)
    }
  end
  
  def throwActiveAt(dice_index)
    # 指定したアクティブダイスを振りなおす
    if dice_index < @active_dice.length
      @active_dice[dice_index] = rand(DICE_PIPS_1..DICE_PIPS_6)
      return true
    else
      return false
    end
  end
  
  def fix(dice_index)
    # 指定したアクティブダイスを確定ダイスにする
    if dice_index < @active_dice.length
      @fixed_dice.push(@active_dice[dice_index])
      @active_dice.delete_at(dice_index)
      return true
    else
      return false
    end
  end
  
  def active_dice_pips()
    # アクティブダイスの目の一覧
    return @active_dice
  end

  def active_dice_pips_at(dice_index)
    # 指定したアクティブダイスの目
    return @active_dice[dice_index]
  end
  
  def fixed_dice_pips()
    # 確定ダイスの目の一覧
    return @fixed_dice
  end
end

class Stock
  # ゲームで利用する山札
  #
  # このクラスは下記で定義する山札のふるまいと、山札に含まれるカードの情報を取得する機能を提供する。
  #
  # - 山札には以下のカードが含まれる(各カードの枚数はプレイヤー人数によって変化する)
  # - 次の条件を満たしているとき山札からカードを引くことができる
  #     - カードの残り枚数が1枚以上である
  #     - ダイスの目(のセット)がカードごとの獲得条件を満たしている
  # - 山札からカードを引くとそのカードの枚数が1枚減る
  #
  # |カード名         |Lv |コスト                             |能力
  # |-----------------|---|-----------------------------------|---------------------
  # |道化師           |0  |出目合計0以上                      |アクティブダイス1個を振り直す
  # |(ペテン師)       |0  |出目合計0以上かつ「道化師」を所持  |手番開始時、ダイスを1個追加
  # |農夫             |I  |同じ出目2つ                        |手番開始時、ダイスを1個追加
  # |メイド           |I  |出目すべてが奇数                   |ダイス1個の出目に1か2か3を加える
  # |哲学者           |I  |出目すべてが偶数                   |ダイス1個の出目を-Xし、別のダイス1個の出目に+Xする(Xは任意の数。結果の出目は1～6の範囲内)
  # |職人             |I  |出目合計15以上                     |出目「1」のダイスを1個追加
  # |衛兵             |I  |同じ出目3つ                        |出目「2」のダイスを1個追加
  # |狩人             |II |同じ出目4つ                        |出目「3」のダイスを1個追加
  # |天文学者         |II |同じ出目2つが2組                   |アクティブダイス1個の出目を、確定したダイスの出目と同じ目に変更
  # |商人             |II |出目合計20以上                     |任意の個数のアクティブダイスを振り直す
  # |貴婦人           |III|同じ出目2つと同じ出目3つ           |任意の個数のアクティブダイスの出目に+1
  # |質屋             |III|出目合計30以上                     |出目「4」のダイスを1個追加
  # |騎士             |III|同じ出目5つ                        |出目「5」のダイスを1個追加
  # |魔術師           |III|連続した出目5つ                    |アクティブダイス1個の出目を、任意の出目に変更
  # |錬金術師         |IV |連続した出目6つ                    |アクティブダイス3個のあいだて、出目を-Xし、他のダイスを+Xする。3個の出目合計は同じに
  # |司教             |IV |同じ出目2つが3組                   |出目「6」のダイスを1個追加
  # |貴族             |IV |同じ出目3つが2組                   |任意の個数のアクティブダイスの出目に+2(出目「5」「6」を除く)
  # |将軍             |IV |同じ出目6つ                        |手番開始時、ダイスを2個追加
  # |王妃             |V  |「国王」を獲得している             |任意の出目のダイスを1個追加
  # |国王             |V  |同じ出目7つ                        |「王妃」を獲得
  #
  # |Lv     |2人  |3人  |4人
  # |-------|-----|-----|-----
  # |0      |5    |5    |5
  # |I      |2    |2    |3
  # |II     |1    |2    |3
  # |III/IV |1    |2    |2
  # |V      |1    |1    |1

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
    # プレイヤー人数に合わせて山札にカードをセットする
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
  
  def draw(card_index, dice)
    # カードを山札から得る
    if draw?(card_index, dice)
      @stock[card_index] -= 1
      return Card.new(card_index)
    else
      return nil
    end
  end
  
  def draw?(card_index, dice)
    # カードを山札から得られるか？

    # 残り枚数がなければ常に取れない
    if @stock[card_index] == 0
      return false
    end
    
    # 取得条件を満たせば取れる
    # TODO カード個別のコスト判定を実装する
    # 今のところ常に取れることにする
    return true
  end
  
  def existKing?()
    # 国王が山札に残っているか？

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

