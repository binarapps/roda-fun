class ReservationSlackConfig
    CONFIG = {
      'channel'          =>  ENV.fetch('CHANNEL'),
      'name'             => 'botsy',
      'incoming_webhook' =>  ENV.fetch('INCOMING_WEBHOOK'),
      'outgoing_token'   => 'secret'
    }
end