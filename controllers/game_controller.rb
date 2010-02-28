class GameController < Cramp::Controller::Websocket
  periodic_timer :update_positions, :every => 0.1
  on_data :receive_message
  class << self; attr_accessor :player_positions end
  @player_positions = {}

  def update_positions
    data = {:type => 'update_positions', :positions => GameController.player_positions}.to_json
    render data
  end
  
  def receive_message(data)
    message = JSON.parse(data)
    type = message['type']    
    self.send("receive_#{type}", message)
  end
  
private

  def receive_register(message)
    player_uuid = UUID.new.generate
    GameController.player_positions[player_uuid] = {:x => 0, :y => 0}
    data = {:type => 'uuid', :uuid => player_uuid, :class_id => self.object_id}.to_json
    render data
  end
  
  def receive_player_move(message)
    player_uuid = message['uuid']
    GameController.player_positions[player_uuid] = {:x => message['data']['x'], :y => message['data']['y']}
  end
  
end