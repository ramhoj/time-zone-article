# frozen_string_literal: true

class UsersController < ApplicationController
  around_action :user_time_zone, only: :show, if: :current_user

  def show
    render json: { time_zone: Time.zone }.to_json
  end

  def without_individial_time_zone
    render json: { time_zone: Time.zone }.to_json
  end

  private

  def current_user
    User.find(params[:id])
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
