class MatchFinalizationJob < ActiveJob::Base
  queue_as :default

  def perform match
    @match = match
    send_notification!
  end

  private
  attr_reader :match

  def send_notification!
    return unless ENV["SLACK_WEBHOOK_URL"]
    notifier.ping(
      "#{victor_name} defeated #{loser_name}",
      attachments: [{
        fields: [{title: home_player_name, value: match.home_score},
                 {title: away_player_name, value: match.away_score}]}]
    )
  end

  def victor_name
    match.victor.name
  end

  def loser_name
    match.loser.name
  end

  def home_player_name
    match.home_player.name
  end

  def away_player_name
    match.away_player.name
  end

  def notifier
    @notifier ||= Slack::Notifier.new(
      ENV["SLACK_WEBHOOK_URL"],
      username: "PorkChop",
      icon_emoji: ":trophy:"
    )
  end
end