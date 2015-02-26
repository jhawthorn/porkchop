class Api::OngoingMatchesController < ApplicationController
  before_filter :match

  authorize_resource :match,
    only: [:show]

  before_filter :authorize_update,
    except: [:show],
    unless: :skip_auth_check?

  def show
    unless match.present?
      head :not_found
    end
  end

  def home_point
    perform record_service(match.home_player)
  end

  def away_point
    perform record_service(match.away_player)
  end

  def toggle_service
    perform match.toggle!(:first_service_by_home_player)
  end

  def rewind
    perform rewind_match
  end

  def finalize
    perform finalize_match
  end

  def destroy
    perform match.try! :destroy
  end

  private

  def match
    @match ||= PingPong::Match.new ongoing_match
  end

  def authorize_update
    authorize! :update, @match
  end

  def skip_auth_check?
    # FIXME: Add api key and check it from headers.
    params[:secret] == "pingpong"
  end

  def finalize_match
    PingPong::Finalization.new(match).finalize!
  end

  def record_service victor
    PingPong::Service.new(match: match, victor: victor).record!
  end

  def rewind_match
    PingPong::Rewind.new(match).rewind!
  end

  def perform(action)
    if action
      render :show
    else
      render :show, status: :unprocessable_entity
    end
  end
end
