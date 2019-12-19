require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'togglv8'
require 'tempus'
require 'rest-client'

Time.zone = 'Brasilia'

class Toogl2DalePonto
  def initialize
    @last_punch_stop = 0.to_tempus
    @last_punch = nil
  end

  def run
    message

    time_entries.each do |time_entry|
      start = Tempus.new(Time.zone.parse(time_entry["start"]), false)

      if (start - @last_punch_stop).to_i > 5.minutes
        request_change(@last_punch) if @last_punch
        request_change(Time.zone.parse(time_entry['start']))
      end

      if time_entry['stop'].present?
        @last_punch = Time.zone.parse(time_entry['stop'])
        @last_punch_stop = Tempus.new(@last_punch, false)
      else
        @last_punch = nil
      end
    end

    request_change(@last_punch) if @last_punch
  end

  private

  def real?
    ENV['REAL_PUNCH'].to_s == 'true'
  end

  def message
    return if real?

    puts "=" * 50
    puts "The request of punches will not be sent to Dale Ponto"
    puts "=" * 50
  end

  def start_date
    Time.zone.parse(ARGV[0]).beginning_of_day.to_s
  end

  def end_date
    Time.zone.parse(ARGV[1]).end_of_day.to_s
  end

  def toggl_token
    ENV['TOGGL_TOKEN']
  end

  def time_entries
    TogglV8::API.new(toggl_token).get_time_entries(start_date: start_date, end_date: end_date)
  end

  def request_change(punch)
    puts "punch: " + punch.to_s

    return unless real?

    RestClient.post(
      "#{ENV['DALEPONTO_API']}/api/v1/punches/request_change",
      {
        punch: {
          date: punch.to_s,
          reason: 'forgot'
        }
      },
      {
      authorization: "Bearer #{ENV['DALEPONTO_TOKEN']}"
      }
    )
  end
end

Toogl2DalePonto.new.run
