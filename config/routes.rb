FbBase::Application.routes.draw do
  match 'facebook/:action' => 'facebook', :as => :facebook
  root :to => 'facebook#index'
end
