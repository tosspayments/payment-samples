Rails.application.routes.draw do
    # add code
    root "payment#keyinform"
  
    get 'payment/keyinapi' => 'payment#keyinform'
    post 'payment/keyinapi' => 'payment#keyinapi'
    
    # end code
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
