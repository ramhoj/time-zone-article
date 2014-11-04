Rails.application.routes.draw do
  resources :users, only: :show do
    get :without_individial_time_zone, on: :member
  end
end
