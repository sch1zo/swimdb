class Item
  include MongoMapper::Document

  key :schedule_id, ObjectId
  belongs_to :schedule

  key :level, Integer, :required => true, :only_integer => true, :in => 0..2, :default => 0
  key :text, String, :required => true
  validates_format_of :text, :key => :lvl0, :with =>/^((\d)(\*|x))?((\d)(\*|x))?(\d+)($|\s|m$|m\s|m,\s)/i, :if => Proc.new { level == 0 }
  validates_format_of :text, :key => :lvl1, :with =>/^((\d)(\*|x))?(\d+)($|\s|m$|m\s|m,\s)/i, :if => Proc.new { level == 1 }
  validates_format_of :text, :key => :lvl2, :with =>/^(\d+)($|\s|m$|m\s|m,\s)/i, :if => Proc.new { level == 2 }
  key :rank, Integer, :required => true, :only_integer => true, :greater_than_or_equal => 0

  #parsed
  key :outer, Integer, :only_integer => true, :greater_than_or_equal => 0
  key :inner, Integer, :only_integer => true, :greater_than_or_equal => 0
  key :distance, Integer, :only_integer => true, :greater_than_or_equal => 0

  before_save :parse_text

  def full_distance
    i = (self.inner == nil) ? 1 : self.inner
    o = (self.outer == nil) ? 1 : self.outer
    self.distance * i * o
  end

  #delete from form workaround
  def delete2
    self.delete
  end
  #private
    def parse_text
      # http://www.rubular.com/r/IafYOKYlU7
      re = /^((\d)(\*|x))?((\d)(\*|x))?(\d+)($|\s|m$|m\s|m,\s)/i
      parse = re.match self.text
      case self.level
        when 0
          self.outer = parse[2]
          self.inner = parse[5]
        when 1
          self.outer = nil
          self.inner = parse[2]
        when 2
          self.outer = nil
          self.inner = nil
      end
      self.distance=parse[7]
      true
    end
end

