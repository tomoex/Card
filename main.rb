#! ruby -Ku

require_relative 'Game'

def select_player(game)
  player_num = 2
  game.join(Player.new, 0)
  game.join(Player.new, 1)
end

def view_dice(active_dices, fix_dices)
  dice_AA = [
    ["+-------+", "+-------+", "+-------+", "+-------+", "+-------+", "+-------+"],
    ["|       |", "| *     |", "| *     |", "| *   * |", "| *   * |", "| *   * |"],
    ["|   *   |", "|       |", "|   *   |", "|       |", "|   *   |", "| *   * |"],
    ["|       |", "|     * |", "|     * |", "| *   * |", "| *   * |", "| *   * |"],
    ["+-------+", "+-------+", "+-------+", "+-------+", "+-------+", "+-------+"]
  ]

  index_AA = [
    ["+-------+", "+-------+", "+-------+", "+-------+", "+-------+", "+-------+"],
    ["|       |", "| *     |", "| *     |", "| *   * |", "| *   * |", "| *   * |"],
    ["|   *   |", "|       |", "|   *   |", "|       |", "|   *   |", "| *   * |"],
    ["|       |", "|     * |", "|     * |", "| *   * |", "| *   * |", "| *   * |"],
    ["+-------+", "+-------+", "+-------+", "+-------+", "+-------+", "+-------+"]
  ]

  prefix_AA =[
    ["           ", "          "],
    ["           ", "          "],
    [" active -> ", " fixed -> "],
    ["           ", "          "],
    ["           ", "          "]
  ]

  if active_dices != nil
    print "           "
    active_dices.each_with_index { |pips, i|
      print "[#{i}]       "
    }
    puts ""
  end

  (0..4).each { |part|
    print prefix_AA[part][0]

    if active_dices != nil
      active_dices.each { |pips|
        print dice_AA[part][pips - 1] + " "
      }
    end

    print prefix_AA[part][1]

    if fix_dices != nil
      fix_dices.each { |pips|
        print dice_AA[part][pips - 1] + " "
      }
    end

    puts ""
  }
end

def main()
  game = Game.new
  # 参加プレイヤー数を決定
  select_player(game)

  # ゲーム開始
  game.start()

  # 国王が獲得されるまで通常ラウンドを行う
  puts "+=============================="
  puts "| 通常ラウンド"
  puts "+=============================="
  while !game.final_round? do
    # 手番となるプレイヤーを指定
    puts "+-------------------------------------------"
    puts "| ラウンド[#{game.round}], player[#{game.now_player_index}]のターン"
    puts "+-------------------------------------------"
    player = game.now_player

    # ダイスを3つ投入
    game.dice.reset()
    game.dice.add()
    game.dice.add()
    game.dice.add()
    # 初期ダイス追加効果を適用
    (0..(player.deck.size - 1)).each{|index|
      if player.deck.card(index).skill.passive?
        player.deck.card(index).skill.use(game.dice, nil)
      end
    }
    puts "#{game.dice.active_num}個の初期ダイス act:#{game.dice.active_dice_pips} fix:#{game.dice.fixed_dice_pips}"
    

    # ダイスがすべて確定するまで繰り返し
    while game.dice.active_num != 0 do
      # ダイスを振る
      game.dice.throwActive()
      puts "#{game.dice.active_num}個、アクティブダイスを振った act:#{game.dice.active_dice_pips} fix:#{game.dice.fixed_dice_pips}"

      # 任意のカード効果を適用する
      while player.deck.availabel_skill_num != 0 do
        puts "能力を使用する(#{player.deck.availabel_card_index_name_list}, -1:終了)"
        card_index = player.use_skill(game.dice)

        if card_index != Player::SKILL_NOT_SELECT
          # カード効果の適用をする
          skill = player.deck.card(card_index).skill
          skill_parameter = player.set_skill_parameter(game.dice, skill.parameter_type)
          success = skill.use(game.dice, skill_parameter)
          if !success
            puts "能力の使用に失敗(入力エラー)"
          end
        else
          break
        end
      end

      # 1個以上のアクティブダイスを確定させる
      init_active_dice_num = game.dice.active_num
      while true do
        puts "確定させるダイスを選ぶ([0]-[#{game.dice.active_num-1}]:選択, -1:終了) act:#{game.dice.active_dice_pips} fix:#{game.dice.fixed_dice_pips}"
        view_dice(game.dice.active_dice_pips, game.dice.fixed_dice_pips)

        dice_index = player.fix_dice(game.dice)

        if dice_index != Player::DICE_NOT_SELECT
          # 確定させる
          game.dice.fix(dice_index)
        else
          if init_active_dice_num - game.dice.active_num >= 1
            # 確定を終了
            break
          else
            puts "最低1個確定する必要ある"
          end
        end

        if game.dice.active_num == 0
          # すべて確定
          break
        end
      end
      puts "ダイスを確定した #{game.dice.fixed_dice_pips}"
    end
    puts "すべてのダイスが確定した #{game.dice.fixed_dice_pips}"
    view_dice(game.dice.active_dice_pips, game.dice.fixed_dice_pips.sort)

    # 山札からカードを取得する
    while true do
      puts "取得するカードを選択する #{player.deck.card_name_list}"
      puts "山札 #{game.stock.card_index_name_list()}"
      card_index = player.select_card(game.dice)
      card = game.stock.draw(card_index, game.dice.active_dice_pips())
      if card != nil
        player.deck.keep(card)
        break
      else
        puts "そのカードを取得できない"
      end
    end

    puts "取得しているカード #{player.deck.card_name_list}"

    # 次のプレイヤーの手番にする
    player.deck.reset()
    game.turn_end()
  end

  # 国王が取得されている場合、最終ラウンドを行う
  if game.final_round?
    puts "+=============================="
    puts "| 最終ラウンド"
    puts "+=============================="
    # 最終ラウンド終了までループ
    while !game.end_of_game?
      # 手番となるプレイヤーを指定
      player = game.now_player

      # ダイスを3つ投入
      # カード効果がある場合、n個のダイスを投入

      # ダイスがすべて確定するまで繰り返し
        # ダイスを振る

        # 任意のカード効果を適用する

        # 1個以上のアクティブダイスを確定させる

      # 同じ出目のダイスが多い場合、国王のカードを取得する

      # 次のプレイヤーの手番にする
      player.deck.reset()
      game.turn_end()
    end
  end

  # 最終ラウンド終了時、国王のカードを持っているプレイヤーが勝者となり、ゲームエンド
  puts "+=============================="
  puts "| ゲーム終了"
  puts "+=============================="
  puts "勝者はプレイヤー[#{game.winner}]だ"
end


main
