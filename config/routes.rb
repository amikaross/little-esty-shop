Rails.application.routes.draw do

  resources :merchants, only: [:index] do 
    resources :items, only: [:index, :show]
  end

  get "/admin/merchants", to: "admin_merchants#index"
  
end
