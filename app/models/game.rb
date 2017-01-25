class Game < ActiveRecord::Base
  belongs_to :user_1, :class_name => 'User'
  belongs_to :user_2, :class_name => 'User'
  belongs_to :winner, :class_name => 'User'
  belongs_to :next_turn_user, :class_name => 'User'

  def add_user(user_id)
    self.user_2_id = user_id
    self.save
  end

  def begin
    self.has_started = true
    self.next_turn_user_id = self.user_1_id
    self.save
  end

  def is_players_turn?(user)
    return self.has_started && self.next_turn_user_id == user.id
  end
end
