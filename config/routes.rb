Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :sites, :defaults => {:format => "json"}
    end
    namespace :v2 do
      resources :ips, :defaults => {:format => "json"}
    end
  end
end
