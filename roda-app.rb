require 'roda'
require 'byebug'
require 'slackbotsy'
require 'open-uri'
require 'set'
require 'rack/csrf'

# require_relative 'configurations/warden'
Dir["./helpers/*.rb"].each {|file| require file }
require_relative 'models'
Dir["./services/*.rb"].each {|file| require file }
Dir["./configurations/*.rb"].each {|file| require file }


class RodaApp < Roda
  # bots init
  opts[:reservation_bot] = Slackbotsy::Bot.new(ReservationSlackConfig::CONFIG)
  opts[:food_bot] = Slackbotsy::Bot.new(FoodSlackConfig::CONFIG)
  plugin :assets, css: ['signin.css', 'reservations.css']
  plugin :render, engine: 'haml'
  plugin :json, :classes=>[Sequel::Model, Array, Hash]
  plugin :default_headers, 'Content-Type'=>'application/json'
  plugin :multi_route
  plugin :shared_vars
  plugin :sinatra_helpers
  plugin :partials
  plugin :flash

  use Rack::Session::Cookie, secret: ENV.fetch('SECRET_TOKEN')
  use Rack::Csrf, :raise => true, :skip_if => api_request?

  use Warden::Manager do |manager|
    manager.scope_defaults :default,
    strategies: [:password],
    action: 'user_sessions/unauthenticated'
    manager.failure_app = self
  end

  route do |r|
    require_relative 'apps/user_sessions'
    require_relative 'apps/user_registrations'
    require_relative 'apps/reservation'

    require_relative 'apps/order'

    r.assets

    # /
    r.root do
      env['warden'].authenticate!
      response['Content-Type'] = 'text/html'
      r.params['day'] ? @day = ( Date.parse r.params['day'] ) : @day = Date.today
      @reservations = Reservation.by_day(@day)
      view('reservations/index')
    end

    # /user_sessions
    r.on 'user_sessions' do
      response['Content-Type'] = 'text/html'
      r.route 'user_sessions'
    end

    # /user_registrations
    r.on 'user_registrations' do
      response['Content-Type'] = 'text/html'
      r.route 'user_registrations'
    end

    # /api
    r.on "api" do
      # /api/reservations
      r.on "reservations" do
        r.route 'reservation'
      end
      # /api/orders
      r.on 'orders' do
        r.route 'order'
      end
    end
  end
end
