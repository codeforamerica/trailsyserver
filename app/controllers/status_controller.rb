class StatusController < ActionController::Base
  respond_to :json

  def check
    trail_count = Trail.count
    if trail_count > 0
      status_string = "ok"
    else
      status_string = "fail DB"
    end
    updated_time = Time.now.to_i
    render json: { status: status_string,
      updated: updated_time,
      dependencies: [ "Postgres" ],
      resources: []
    }
  end
end