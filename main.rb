#! ruby -Ku

require_relative 'Game'

def select_player(game)
  player_num = 1
  game.join(Player.new, 0)
  # game.join(Player.new, 1)
end

# ダイスを表示
def print_dice(fixed_dice_pips, active_dice_pips)
  (0..(fixed_dice_pips.length - 1)).each{ |fixed_index|
    print "[#{fixed_dice_pips[fixed_index]}]"
  }
  print "|"
  (0..(active_dice_pips.length - 1)).each{ |active_index|
    print "[#{active_dice_pips[active_index]}]"
  }
end

# アニメーション付きでダイスを表示
def print_animation_dice(fixed_dice_pips, active_dice_pips)
  (0..9).each{ |i|
        print "\r"
        print_dice(fixed_dice_pips, Array.new(active_dice_pips.length){rand(5)})
        sleep 0.1
      }
      print "\r"
      print_dice(fixed_dice_pips, active_dice_pips)
      sleep 0.5
      puts ""
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
    puts "#{game.dice.active_num}個の初期ダイスを入手"

    # ダイスがすべて確定するまで繰り返し
    while game.dice.active_num != 0 do
      # ダイスを振る
      game.dice.throwActive()
      # puts "#{game.dice.active_num}個、アクティブダイスを振った act:#{game.dice.active_dice_pips} fix:#{game.dice.fixed_dice_pips}"
      puts "#{game.dice.active_num}個、アクティブダイスを振った"
      print_animation_dice(game.dice.fixed_dice_pips, game.dice.active_dice_pips)

      # (利用可能ならば)任意のカード効果を適用する
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

      # (1個以上の)アクティブダイスを確定させる
      init_active_dice_num = game.dice.active_num
      while true do
        puts "確定させるダイスを選ぶ(ダイスの出目を入力、複数指定はスペース区切り)"

        # 確定するアクティブダイスをプレイヤーが選択する
        dice_pips = player.fix_dice(game.dice)

        # アクティブダイスを確定する
        dice_pips.each{|pips|
          # ダイスの出目を内部的なindexに置き換えてfix()を呼ぶ
          (0..(game.dice.active_num-1)).each{|active_index|
            if game.dice.active_dice_pips_at(active_index) == pips
              game.dice.fix(active_index)
              break
            end
          }
        }

        # アクティブダイスが0個(すべて確定) or 1個以上確定
        if game.dice.active_num == 0 || init_active_dice_num - game.dice.active_num >= 1
          # すべて確定
          break
        else
          puts "最低1個確定する必要ある"
        end
      end
      puts "#{game.dice.fixed_dice_pips} のダイスを確定した"
    end
    puts "すべてのダイスが確定した #{game.dice.fixed_dice_pips}"

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
