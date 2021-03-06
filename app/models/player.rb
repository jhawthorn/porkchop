class Player < ActiveRecord::Base
  BASE_ELO = 1000

  scope :active, -> { where(active: true) }

  has_many :achievements
  has_many :points, foreign_key: 'victor_id'
  has_many :victories, class_name: "Match", foreign_key: 'victor_id'
  has_many :elo_ratings
  has_many :season_memberships
  has_many :seasons, through: :season_memberships
  has_many :streaks, class_name: "Stats::Streak"

  validates :name, presence: true

  after_save :record_rating

  def matches
    Match.where "matches.home_player_id = :id OR matches.away_player_id = :id",
                id: id
  end

  def losses
    matches.finalized.where.not(victor: self)
  end

  def matches_since_last_played
    if last_played_at = matches.order(created_at: :asc).last.try(:created_at)
      Match.where("created_at > ?", last_played_at).count
    else
      Float::INFINITY
    end
  end

  def matches_against(opponent)
    matches.finalized.where(
      "away_player_id = :opponent OR home_player_id = :opponent",
      opponent: opponent
    )
  end

  def opponents
    Player.where(id: opponent_ids)
  end

  attr_writer :elo

  def elo
    elo_ratings.most_recent_rating || BASE_ELO
  end

  def elo_on(date)
    elo_ratings.rating_on(date) || BASE_ELO
  end

  def all_achievements
    achievements + unearned_achievements
  end

  def unearned_achievements
    Achievement.unearned(self)
  end

  def last_played_at
    matches.maximum(:created_at) || Time.at(0)
  end

  def stats
    @stats ||= Stats::Personal.new(self)
  end

  def current_streak
    streaks.active.first
  end

  private

  def record_rating
    return unless @elo
    elo_ratings.create(rating: @elo)
  end

  def opponent_ids
    matches.
      finalized.
      pluck(:away_player_id, :home_player_id).
      flatten.
      reject { |player_id| player_id == id }
  end
end
