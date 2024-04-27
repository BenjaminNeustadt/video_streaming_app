module UserHelpers

  def update_current_user_time_on_site(session_id, time)
    users = User.all
    user_to_find = users.find_by(session_id: session_id)
    user_to_find.update(time_on_site: time)
  end

end
