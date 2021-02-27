Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/', to: 'playlist#View'

  post 'ajax/ViewTracks'
  post 'ajax/play'

  get 'ajax/status'

end
