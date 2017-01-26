class Game < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :user_1, :class_name => 'User'
  belongs_to :user_2, :class_name => 'User'
  belongs_to :winner, :class_name => 'User'
  belongs_to :next_turn_user, :class_name => 'User'

  def add_user(user_id)
    self.user_2_id = user_id
    self.save
  end

  def get_opponent(user_id)
    puts "user_id: #{user_id}"
    puts "self: #{self.inspect}"

    if user_id == self.user_1_id
      return self.user_2
    elsif user_id == self.user_2_id
      return self.user_1
    end

    return nil
  end

  def begin
    self.has_started = true
    self.next_turn_user_id = self.user_1_id
    self.save
  end

  def is_players_turn?(user)
    return self.has_started && self.next_turn_user_id == user.id
  end

  def switch_to_next_players_turn
    self.next_turn_user_id = self.next_turn_user_id == user_1_id ? user_2_id : user_1_id
    self.save
  end

  def is_over?
    return !winner_id.nil?
  end

  def update_winner(user)
    self.winner_id = user.id
    self.save
  end
end
