class Stats::SeasonPersonal
  include Comparable

  attr_reader :player

  def initialize(season, player)
    @season, @player = season, player
  end

  def <=>(other)
    [win_ratio, point_differential] <=> [other.win_ratio, other.point_differential]
  end

  def matches_played
    matches.size
  end

  def matches_won
    matches.select do |match|
      match.victor_id == player.id
    end.size
  end

  def matches_lost
    matches_played - matches_won
  end

  def win_ratio
    return format_ratio(0) if matches_played.zero?
    format_ratio (matches_won.to_f / matches_played.to_f)
  end

  def points_for
    points.select do |match|
      match.victor_id == player.id
    end.size
  end

  def points_against
    points.select do |match|
      match.victor_id != player.id
    end.size
  end

  def point_differential
    points_for - points_against
  end

  private
  attr_reader :season

  def matches
    @matches ||= season.matches.finalized.where("home_player_id = :player OR away_player_id = :player", player: player)
  end

  def points
    @points ||= matches.map(&:points).flatten
  end

  def format_ratio(ratio)
    ("%.3f" % ratio).sub(/\A0/, "")
  end
end
