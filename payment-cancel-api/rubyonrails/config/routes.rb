Rails.application.routes.draw do
    # add code
    root "payment#cancelform"
  
    get 'payment/cancelapi' => 'payment#cancelform'
    post 'payment/cancelapi' => 'payment#cancelapi'
    
    # end code
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
