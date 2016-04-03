#! ruby -Ku

require_relative 'Card'

class Player
  DICE_NOT_SELECT = -1
  SKILL_NOT_SELECT = -1
  
  def initialize()
    @deck = Deck.new
  end
  
  def use_skill(dice)
    print "> "
    skill_index = STDIN.gets
    return skill_index.to_i
  end
  
  def fix_dice(dice)
    print "> "
    dice_index = STDIN.gets
    return dice_index.to_i
  end
  
  def select_card(dice)
    print "> "
    dice_index = STDIN.gets
    return dice_index.to_i
  end
  
  def set_skill_parameter(dice, parameter_type)
    parameter = Skill::Parameter.new
    
    case parameter_type
    when Skill::NONE then
      # 何もしない
    when Skill::DICE_ABS_PIPS then
      while true
        print ">[出目] "
        pips = STDIN.gets.to_i
        if Dice::DICE_PIPS_1 <= pips and pips <= Dice::DICE_PIPS_6
          parameter.abs_pips_n.push(pips)
          break
        end
      end
    when Skill::DICE_INDEX then
      puts "アクティブダイス選択([0]-[#{dice.active_num-1}])#{dice.active_dice_pips}"
      print "> "
      parameter.active_dice_index_n.push(STDIN.gets.to_i)
    when Skill::DICE_INDEX_AND_DIFF_PIPS then
      puts "アクティブダイス選択([0]-[#{dice.active_num-1}])#{dice.active_dice_pips}"
      print "> "
      parameter.active_dice_index_n.push(STDIN.gets.to_i)
      puts "変化量(1:+1, 2:+2, 3:+3)"
      print "> "
      parameter.diff_pips_n.push(STDIN.gets.to_i)
    when Skill::DICE_INDEX_AND_DIFF_PIPS_2 then
    when Skill::DICE_INDEX_AND_DIFF_PIPS_3 then
    when Skill::DICE_INDEX_AND_ABS_PIPS then
    when Skill::DICE_INDEX_N then
      puts "アクティブダイス選択([0]-[#{dice.active_num-1}])#{dice.active_dice_pips}"
      print "> "
      dice_index = STDIN.gets.split(" ")
      dice_index.each { |index|
        parameter.active_dice_index_n.push(index.to_i)
      }
    end
    
    return parameter
  end
  
  def deck()
    return @deck
  end
end


class Deck
  def initialize()
    @deck = []
  end
  
  def additional_dice()
  end
  
  def keep(card)
    @deck.push(card)
  end
  
  def card(index)
    return @deck[index]
  end
  
  def reset()
    @deck.each{ |card|
      card.skill.reset()
    }
  end
  
  def size()
    return @deck.length
  end
  
  def availabel_skill_num()
    cnt = 0
    @deck.each{|card|
      if !card.skill.used
        cnt += 1
      end
    }
    return cnt
  end
  
  def card_name_list()
    # デバッグ用
    array = []
    @deck.each{|card|
      array.push(card.name_short)
    }
    return array
  end
  
  def card_index_name_list()
    # デバッグ用
    array = []
    cnt = 0
    @deck.each{|card|
      array.push("#{cnt.to_s}:#{card.name_short}")
      cnt += 1
    }
    return array
  end
  
  def availabel_card_index_name_list()
    # デバッグ用
    array = []
    cnt = 0
    @deck.each{|card|
      if !card.skill.used
        array.push("#{cnt.to_s}:#{card.name_short}")
      end
      cnt += 1
    }
    return array
  end
end

