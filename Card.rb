#! ruby -Ku

require_relative 'Skill'

class Card
  UNDEFINE      = -1  # 未定義
  CLOWN         = 0   # 道化師
  FAKER         = 1   # ペテン師
  FARMER        = 2   # 農夫
  HOUSEMAID     = 3   # メイド
  PHILOSOPHER   = 4   # 哲学者
  CRAFTSMAN     = 5   # 職人
  GUARD         = 6   # 衛兵
  HUNTER        = 7   # 狩人
  ASTRONOMICAL  = 8   # 天文学者
  MERCHANT      = 9   # 商人
  GRANDE_DAME   = 10  # 貴婦人
  PAWNSHOP      = 11  # 質屋
  KNIGHT        = 12  # 騎士
  MAGICIAN      = 13  # 魔術師
  ALCHEMIST     = 14  # 錬金術師
  BISIHOP       = 15  # 司教
  NOBLE         = 16  # 貴族
  GEENERAL      = 17  # 将軍
  QUEEN         = 18  # 王妃
  KING          = 19  # 国王
  TYPE_NUM      = 20  # カードの種類
  
  CARD_NAME =
  [
    "道化師",
    "ペテン師",
    "農夫",
    "メイド",
    "哲学者",
    "職人",
    "衛兵",
    "狩人",
    "天文学者",
    "商人",
    "貴婦人",
    "質屋",
    "騎士",
    "魔術師",
    "錬金術師",
    "司教",
    "貴族",
    "将軍",
    "王妃",
    "国王"
  ]
  
  CARD_SHROT_NAME =
  [
    "道",
    "ペ",
    "農",
    "メ",
    "哲",
    "職",
    "衛",
    "狩",
    "天",
    "商",
    "婦",
    "質",
    "騎",
    "魔",
    "錬",
    "司",
    "貴",
    "将",
    "妃",
    "王"
  ]
  
  def initialize(type)
    @type = type
    
    skill_list =
    [
      SkillAddActive1.new,        # 道化師
      SkillAddActive1.new,        # ペテン師
      SkillAddActive1.new,        # 農夫
      SkillAddActive1.new,        # メイド
      SkillAddActive1.new,        # 哲学者
      SkillAddActive1.new,        # 職人
      SkillAddActive2.new,        # 衛兵
      SkillAddActive3.new,        # 狩人
      SkillAddActive1.new,        # 天文学者
      SkillAddActive1.new,        # 商人
      SkillAddActive1.new,        # 貴婦人
      SkillAddActive4.new,        # 質屋
      SkillAddActive5.new,        # 騎士
      SkillAddActive1.new,        # 魔術師
      SkillAddActive1.new,        # 錬金術師
      SkillAddActive6.new,        # 司教
      SkillAddActive1.new,        # 貴族
      SkillAddActive1.new,        # 将軍
      SkillAddActiveN.new,        # 王妃
      SkillAddActive1.new,        # 国王
    ]
    
    @skill = skill_list[type]
  end
  
  attr_reader :type
  attr_reader :skill
  
  def name()
    return CARD_NAME[@type]
  end
  
  def name_short()
    return CARD_SHROT_NAME[@type]
  end
end

