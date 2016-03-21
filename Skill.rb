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
end


class SkillAddInit < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive1 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_1)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive2 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_2)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive3 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_3)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive4 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_4)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive5 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_5)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActive6 < Skill
  def use(dice, parameter)
    dice.add(Dice::DICE_PIPS_6)
    @used = true
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillAddActiveN < Skill
  def use(dice, parameter)
    dice_pips = @parameter.active_dice_index_n[0]
    dice.add(dice_pips)
  end
  
  def parameter_type()
    return Skill::DICE_ABS_PIPS
  end
end

class SkillChangePlus123 < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillChangePlus1N < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
  end
end

class SkillChangePlus2N < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::NONE
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
  end
  
  def parameter_type()
    return Skill::DICE_INDEX
  end
end

class SkillReThrowN < Skill
  def use(dice, parameter)
  end
  
  def parameter_type()
    return Skill::DICE_INDEX
  end
end


