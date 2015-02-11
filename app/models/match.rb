class Match < ActiveRecord::Base
  belongs_to :home_player, class_name: "Player"
  belongs_to :away_player, class_name: "Player"
  belongs_to :victor, class_name: "Player"

  has_many :points

  validates :home_player, :away_player, presence: true

  scope :ongoing, -> { where finalized_at: nil }

  def home_points
    points.where(victor: home_player)
  end

  def away_points
    points.where(victor: away_player)
  end

  def finished?
    highest_score > 10 && score_differential >= 2
  end

  def finalize!
    return false if !finished? || finalized?
    self.finalized_at = Time.zone.now
    save
  end

  def finalized?
    !!finalized_at
  end

  private

  def highest_score
    [home_points.count, away_points.count].max
  end

  def score_differential
    (away_points.count - home_points.count).abs
  end
end