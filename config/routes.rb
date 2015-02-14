Rails.application.routes.draw do

  namespace :api, path: '/', constraints: { subdomain: 'api' } do
    namespace :v1 do
      resources :sites, except: [:new, :edit]
    end
  end

  # namespace path_helper hackery!
  get '/v1/sites/:url', to: 'sites#show', as: :site

end
