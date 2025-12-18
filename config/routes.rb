# frozen_string_literal: true

Rails.application.routes.draw do
  get '/download', to: 'downloads#index', as: 'download'
  get '/download/:set', to: 'downloads#download', as: 'download_set',
                        constraints: { set: /pubs|author|department|school/ }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/webauth/login', to: 'authentication#login', as: 'login'
  get '/webauth/logout', to: 'authentication#logout', as: 'logout'
  get '/test_login/:id', to: 'authentication#test_login', as: 'test_login', param: :id if Rails.env.test?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root 'static_pages#home'
  get '/about', to: 'static_pages#about', as: 'about'

  get 'orcid-adoption', to: 'orcid_adoption#show', as: 'orcid_adoption_dashboard'
  get '/orcid_adoption/stanford-overview', to: 'orcid_adoption#stanford_overview',
                                           as: 'orcid_adoption_stanford_overview'
  get '/orcid_adoption/department-details', to: 'orcid_adoption#department_details',
                                            as: 'orcid_adoption_department_details'
  get '/orcid_adoption/researcher-details', to: 'orcid_adoption#researcher_details',
                                            as: 'orcid_adoption_researcher_details'

  # open access routes
  get 'open-access', to: 'open_access#show', as: 'open_access_dashboard'
  get '/open-access/stanford-overview', to: 'open_access#stanford_overview', as: 'open_access_stanford_overview'
  get '/open-access/school-overview', to: 'open_access#school_overview', as: 'open_access_school_overview'
  get '/open-access/school-details', to: 'open_access#school_details', as: 'open_access_school_details'
  get '/open-access/department-details', to: 'open_access#department_details', as: 'open_access_department_details'

  # publication routes
  get 'publications', to: 'publications#show', as: 'publications_dashboard'
  get '/publications/stanford-overview', to: 'publications#stanford_overview', as: 'publications_stanford_overview'
  get '/publications/type-overview', to: 'publications#type_overview', as: 'publications_type_overview'
  get '/publications/school-details', to: 'publications#school_details', as: 'publications_school_details'
  get '/publications/department-details', to: 'publications#department_details', as: 'publications_department_details'

  get '/documentation/:faq', to: 'documentation#show', as: 'documentation',
                             constraints: { faq: /#{Settings.docs.keys.join('|')}/ }
end
