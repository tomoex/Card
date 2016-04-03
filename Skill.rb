#! ruby -Ku

class Skill
  NONE                          = 0   # パラメータなし
  DICE_ABS_PIPS                 = 1   # 出目
  DICE_INDEX                    = 2   # アクティブダイスのindex
  DICE_INDEX_AND_DIFF_PIPS      = 3   # アクティブダイスのindex + 出目の変化量
  DICE_INDEX_AND_DIFF_PIPS_2    = 4   # (アクティブダイスのindex + 出目の変化量) * 2
  DICE_INDEX_AND_DIFF_PIPS_3    = 5   # (アクティブダイスのindex + 出目の変化量) * 3
  DICE_INDEX_AND_ABS_PIPS       = 6   # アクティブダイスのindex + 出目
  DICE_INDEX_N                  = 7   # アクティブダイスのindexの任意個の組
  
  class Parameter
    def initialize()
      @active_dice_index_n  = []
      @abs_pips_n           = []
      @diff_pips_n          = []
    end
    
    attr_accessor :active_dice_index_n
    attr_accessor :abs_pips_n
    attr_accessor :diff_pips_n
  end
  
  def initialize()
    @used = false
  end
  
  attr_reader :used
  
  def reset()
    @used = false
  end
  
  def use(dice, parameter)
  end
  
  def parameter_type()
  end

  def passive?()
    return false
  end
end


class SkillAddInit1 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_1)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end

  def passive?()
    return true
  end
end

class SkillAddInit2 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_1)
    dice.add(Dice::DICE_PIPS_1)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end

  def passive?()
    return true
  end
end

class SkillAddActive1 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_1)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive2 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_2)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive3 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_3)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive4 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_4)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive5 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_5)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive6 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_6)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActiveN < Skill
  def use(dice, parameter)
    dice_pips = parameter.abs_pips_n[0]
    
    # ダイス出目の範囲チェック
    if !(Dice::DICE_PIPS_1 <= dice_pips and dice_pips <= Dice::DICE_PIPS_6)
      return false
    end
    
    dice.add(dice_pips)
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::DICE_ABS_PIPS
  end
end

class SkillChangePlus123 < Skill
  def use(dice, parameter)
    dice_index = parameter.active_dice_index_n[0]
    dice_diff  = parameter.diff_pips_n[0]
    
    # アクティブダイス選択の範囲チェック
    if !(0 <= dice_index and dice_index < dice.active_num)
      return false
    end
    # ダイス変化量の範囲チェック
    if !(1 <= dice_diff and dice_diff <= 3)
      return false
    end
    
    dice_pips = dice.active_dice_pips(dice_index) + dice_diff
    
    # ダイスの出目の範囲チェック
    if !(Dice::DICE_PIPS_1 <= dice_pips and dice_pips <= Dice::DICE_PIPS_6)
      return false
    end
    
    # 出目変更
    dice.change(dice_index, dice_pips)
    
    @used = true
  end
  
  def parameter_type()
    return Skill::DICE_INDEX_AND_DIFF_PIPS
  end
end

class SkillChangePlusNN < Skill
  def use(dice, parameter, diff)
    dice_index = parameter.active_dice_index_n.clone()
    
    # アクティブダイス選択の範囲チェック
    dice_index.each { |index|
      if !(0 <= index and index < dice.active_num)
        return false
      end
    }
    # アクティブダイス選択の重複チェック                                                                                                                                                                                                                                                                                                                                  
    if dice_index.uniq.length != parameter.active_dice_index_n.uniq.length
      return false
    end
    
    dice_pips = []
    dice.active_dice_pips.each { |pips|
      dice_pips.push(pips + diff) 
    }
    
    # ダイスの出目の範囲チェック
    dice_pips.each { |pips|
      if !(Dice::DICE_PIPS_1 <= pips and pips <= Dice::DICE_PIPS_6)
        return false
      end
    }
    
    # 出目変更
    dice_index.each_with_index { |index, i|
      dice.change(index, dice_pips[i])
    }
    
    @used = true
  end
  
  def parameter_type()
    return Skill::DICE_INDEX_N
  end
end


class SkillChangePlus1N < SkillChangePlusNN
  def use(dice, parameter)
    super(dice, parameter, 1)
  end
end

class SkillChangePlus2N < SkillChangePlusNN
  def use(dice, parameter)
    super(dice, parameter, 2)
  end
end

class SkillChangePlusMinus < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillChangeReplace < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillReThrow < Skill
  def use(dice, parameter)
    dice_index = parameter.active_dice_index_n[0]
    
    # アクティブダイス選択の範囲チェック
    if !(0 <= dice_index and dice_index < dice.active_num)
      return false
    end
    
    # ダイスを振りなおす
    dice.throwActiveAt(dice_index)
    
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::DICE_INDEX
  end
end

class SkillReThrowN < Skill
  def use(dice, parameter)
    dice_index = parameter.active_dice_index_n.clone()
    
    # アクティブダイス選択の範囲チェック
    dice_index.each { |index|
      if !(0 <= index and index < dice.active_num)
        return false
      end
    }
    # アクティブダイス選択の重複チェック                                                                                                                                                                                                                                                                                                                                  
    if dice_index.uniq.length != parameter.active_dice_index_n.uniq.length
      return false
    end
    
    # ダイスを振りなおす
    dice_index.each { |index|
      dice.throwActiveAt(index)
  }
    
    @used = true
    
    return true
  end
  
  def parameter_type()
    return Skill::DICE_INDEX_N
  end
end


