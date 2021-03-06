class Matchup
  include ActiveModel::Validations

  EPOCH = Time.at(0)

  validate :exactly_two_players

  def self.all(players:)
    players.combination(2).map { |players| new(*players) }
  end

  def initialize(*players)
    @players = Set.new(players)
  end

  attr_reader :players

  def ==(other_object)
    if other_object.respond_to?(:players)
      players == other_object.players
    else
      super
    end
  end

  def matches_since_last_played
    if last_played_at = match_history.last.try!(:created_at)
      Match.where("created_at > ?", last_played_at).count
    else
      Float::INFINITY
    end
  end

  def match_history
    p1, p2 = *players
    Match.
      where("home_player_id = :p1 AND away_player_id = :p2 OR home_player_id = :p2 AND away_player_id = :p1",
            p1: p1,
            p2: p2).
      order(created_at: :asc)
  end

  private

  def exactly_two_players
    unless players.length == 2
      errors.add(:base, "Must have exactly two players.")
    end
  end
end
