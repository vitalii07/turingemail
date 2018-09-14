require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.default_url_options[:host] = $config.http_host

Rails.application.routes.draw do
  #############
  ### Admin ###
  #############

  mount Upmin::Engine => '/admin'

  ###########
  ### API ###
  ###########

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      #######################
      ### API - Analytics ###
      #######################

      get '/email_reports/ip_stats_report', to: 'email_reports#ip_stats_report'
      get '/email_reports/volume_report', to: 'email_reports#volume_report'
      get '/email_reports/contacts_report', to: 'email_reports#contacts_report'
      get '/email_reports/attachments_report', to: 'email_reports#attachments_report'
      get '/email_reports/lists_report', to: 'email_reports#lists_report'
      get '/email_reports/threads_report', to: 'email_reports#threads_report'
      get '/email_reports/folders_report', to: 'email_reports#folders_report'
      get '/email_reports/impact_report', to: 'email_reports#impact_report'

      ##################
      ### API - Apps ###
      ##################

      resources :apps, only: [:create, :index]
      post '/apps/install/:app_uid', to: 'apps#install'
      delete '/apps/uninstall/:app_uid', to: 'apps#uninstall'
      delete '/apps/:app_uid', to: 'apps#destroy'
      post '/apps/test', to: 'apps#test'

      ############################
      ### API - Authentication ###
      ############################

      resources :api_sessions, only: [:create]
      delete '/signout', to: 'api_sessions#destroy'

      ############################
      ### API - Delayed Emails ###
      ############################

      resources :delayed_emails, only: [:index]
      delete '/delayed_emails/:delayed_email_uid', :to => 'delayed_emails#destroy'

      ####################
      ### API - Emails ###
      ####################

      get '/emails/show/:email_uid', to: 'emails#show'
      post '/emails/set_seen', to: 'emails#set_seen'
      post '/emails/move_to_folder', to: 'emails#move_to_folder'
      post '/emails/apply_gmail_label', to: 'emails#apply_gmail_label'
      post '/emails/remove_from_folder', to: 'emails#remove_from_folder'
      post '/emails/trash', to: 'emails#trash'

      ############################
      ### API - Email Accounts ###
      ############################

      post '/email_accounts/send_email', to: 'email_accounts#send_email'
      post '/email_accounts/send_email_delayed', to: 'email_accounts#send_email_delayed'
      post '/email_accounts/sync', to: 'email_accounts#sync'
      post '/email_accounts/search_threads', to: 'email_accounts#search_threads'
      post '/email_accounts/drafts', to: 'email_accounts#create_draft'
      put '/email_accounts/drafts', to: 'email_accounts#update_draft'
      post '/email_accounts/send_draft', to: 'email_accounts#send_draft'
      post '/email_accounts/delete_draft', to: 'email_accounts#delete_draft'
      get '/email_accounts/cleaner_overview', to: 'email_accounts#cleaner_overview'
      post '/email_accounts/cleaner_report', to: 'email_accounts#create_cleaner_report'
      get '/email_accounts/cleaner_report', to: 'email_accounts#cleaner_report'
      delete '/email_accounts/cleaner_report', to: 'email_accounts#destroy_cleaner_report'
      put '/email_accounts/cleaner_report', to: 'email_accounts#apply_cleaner'

      ###############################
      ### API - Email Attachments ###
      ###############################

      get '/email_attachments', to: 'email_attachments#index'
      get '/email_attachments/:attachment_uid', to: 'email_attachments#show'
      get '/email_attachments/download/:attachment_uid', to: 'email_attachments#download'
      delete '/email_attachments/:attachment_uid', :to => 'email_attachments#destroy'

      #################################
      ### API - Email Conversations ###
      #################################

      resources :email_conversations, only: [:index, :show]

      ###########################
      ### API - Email Folders ###
      ###########################

      resources :email_folders, only: [:index]

      #########################
      ### API - Email Rules ###
      #########################

      resources :email_filters, only: [:create, :index, :update, :destroy]
      get '/email_filters/recommended_filters', to: 'email_filters#recommended_filters'

      #######################
      ### API - Reminders ###
      #######################
      get '/reminders', to: 'reminders#index'
      post '/reminders/:id/change_time', to: 'reminders#update'
      put '/reminders/:id', to: 'reminders#remove_reminder'

      ##############################
      ### API - Email Signatures ###
      ##############################

      resources :email_signatures, only: [:create, :index]
      get '/email_signatures/:email_signature_uid', to: 'email_signatures#show'
      patch '/email_signatures/:email_signature_uid', :to => 'email_signatures#update'
      delete '/email_signatures/:email_signature_uid', :to => 'email_signatures#destroy'

      #############################
      ### API - Email Templates ###
      #############################

      resources :email_templates, only: [:create, :index]
      patch '/email_templates/:email_template_uid', :to => 'email_templates#update'
      delete '/email_templates/:email_template_uid', :to => 'email_templates#destroy'

      resources :email_template_categories, only: [:create, :index]
      patch '/email_template_categories/:email_template_category_uid', :to => 'email_template_categories#update'
      delete '/email_template_categories/:email_template_category_uid', :to => 'email_template_categories#destroy'

      ###########################
      ### API - Email Threads ###
      ###########################

      get '/email_threads/show/:email_thread_uid', to: 'email_threads#show'
      get '/email_threads/stats/:email_thread_uid', to: 'email_threads#stats'
      get '/email_threads/subjects/:email_thread_uid', to: 'email_threads#subjects'
      post '/email_threads/retrieve', to: 'email_threads#retrieve'
      get '/email_threads/inbox', to: 'email_threads#inbox'
      get '/email_threads/in_folder', to: 'email_threads#in_folder'
      post '/email_threads/move_to_folder', to: 'email_threads#move_to_folder'
      post '/email_threads/apply_gmail_label', to: 'email_threads#apply_gmail_label'
      post '/email_threads/remove_from_folder', to: 'email_threads#remove_from_folder'
      post '/email_threads/trash', to: 'email_threads#trash'
      post '/email_threads/snooze', to: 'email_threads#snooze'

      ############################
      ### API - Email Trackers ###
      ############################

      resources :email_trackers, only: [:index]

      #################################
      ### API - Twitter Friendships ###
      #################################

      resources :twitter_friendships, only: [:create, :show]

      ###############################
      ### API - Twitter Timelines ###
      ###############################

      resources :twitter_timelines, only: :show

      #############################
      ### API - Google Contacts ###
      #############################

      get '/google_contacts/show', to: 'google_contacts#show'

      #################################
      ### API - Inbox Cleaner Rules ###
      #################################

      resources :inbox_cleaner_rules, only: [:create, :index]
      delete '/inbox_cleaner_rules/:inbox_cleaner_rule_uid', :to => 'inbox_cleaner_rules#destroy'

      ################################
      ### API - List Subscriptions ###
      ################################

      resources :list_subscriptions, only: [:index]
      delete '/list_subscriptions/unsubscribe', :to => 'list_subscriptions#unsubscribe'
      post '/list_subscriptions/resubscribe', :to => 'list_subscriptions#resubscribe'

      ##################
      ### API - Logs ###
      ##################

      post '/log', to: 'logs#log'

      ####################
      ### API - People ###
      ####################

      post 'people/recent_thread_subjects', to: 'people#recent_thread_subjects'
      get 'people/search/:query', to: 'people#search'
      get 'people/search', to: 'people#search'

      ###################
      ### API - Skins ###
      ###################

      resources :skins, only: [:index]

      ############################
      ### API - Tracked Emails ###
      ############################

      resources :email_trackers, only: [:index]

      ###################
      ### API - Users ###
      ###################

      resources :users, only: [:create]
      get '/users/current', to: 'users#current'
      get '/users/installed_apps', to: 'users#installed_apps'
      post '/users/declare_email_bankruptcy', to: 'users#declare_email_bankruptcy'
      get '/users/upload_attachment_post', to: 'users#upload_attachment_post'
      patch '/users/update', :to => 'users#update'
      get '/users/dashboard', to: 'users#dashboard'
      #################################
      ### API - User Configurations ###
      #################################

      get '/user_configurations', to: 'user_configurations#show'
      put '/user_configurations', to: 'user_configurations#update'
      patch '/user_configurations', to: 'user_configurations#update'

      ##############################
      ### API - Website Previews ###
      ##############################

      get '/website_previews/proxy', to: 'website_previews#proxy'
    end
  end

  ######################
  ### Authentication ###
  ######################

  devise_for :users,
             :controllers => { :registrations => "registrations" }

  resources :users, only: [:new, :create, :show]

  devise_scope :user do
    get "/signout" => "devise/sessions#destroy"
  end

  get "/30daytrial" =>"static_pages#signup_thirty_day_trial"
  get "/3monthtrial" =>"static_pages#signup_three_month_trial"

  resources :gmail_sessions, only: [:new, :create, :destroy, :switch_account]

  get '/signin',  to: 'gmail_sessions#new'
  get "/SignUp", to: "static_pages#signup"
  get "/signup", to: "static_pages#signup"
  delete '/signout', to: 'gmail_sessions#destroy'
  delete '/switch_account', to: 'gmail_sessions#switch_account'

  #################
  ### Callbacks ###
  #################

  get '/gmail_oauth2_callback', to: 'gmail_accounts#o_auth2_callback'
  delete '/gmail_o_auth2_remove', to: 'gmail_accounts#o_auth2_remove'
  post '/gmail_pubsub_callback', to: 'gmail_pubsub#sync_email'
  get '/outlook_oauth2_callback', to: 'outlook_accounts#o_auth2_callback'
  get '/yahoo_mail_oauth2_callback', to: 'yahoo_mail_accounts#o_auth2_callback'
  get '/twitter_oauth1_callback', to: 'twitter_accounts#o_auth1_callback'

  ############
  ### Demo ###
  ############

  get '/live_demo', to: 'demo#live_demo'

  ################
  ### Internal ###
  ################

  get '/loader', to: 'static_pages#loader'
  get '/mail', to: 'static_pages#mail'
  get '/users/show',  to: 'users#show'

  #######################
  ### Landing Website ###
  #######################

  root to: 'static_pages#homepage'

  get '/story', to: 'static_pages#story'
  get '/benefits', to: 'static_pages#benefits'
  match '/demo', to: 'static_pages#demo', via: [:get, :post]
  get '/pricing', to: 'static_pages#pricing'
  get '/features', to: 'static_pages#features'
  get '/signup_enterprise', to: 'static_pages#signup_enterprise'
  get '/signup_individual', to: 'static_pages#signup_individual'
  get '/signup_introductory', to: 'static_pages#signup_introductory'
  get '/signup_payment', to: 'static_pages#signup_payment'
  get '/signup_accounts', to: 'static_pages#signup_accounts'
  match '/signup_aol_account', to: 'static_pages#signup_aol_account', via: [:get, :post]
  match '/signup_generic_imap_account', to: 'static_pages#signup_generic_imap_account', via: [:get, :post]
  match '/signup_icloud_account', to: 'static_pages#signup_icloud_account', via: [:get, :post]
  match '/waitlist', to: 'static_pages#waitlist', via: [:get, :post]
  get '/confirm', to: 'static_pages#confirm'
  get '/take_me_to_turing', to: 'static_pages#take_me_to_turing'

  #############################
  ### Payment/Subscriptions ###
  #############################

  mount Payola::Engine => '/payola', as: :payola
  get 'signup_pay', to: 'subscriptions#signup_pay'
  resources :subscriptions

  ###############
  ### Sidekiq ###
  ###############

  constraints lambda {|request| AdminConstraint.new.matches? request } do
    namespace :monitoring do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  ###############
  ### Testing ###
  ###############

  if Rails.env.test?
    get '/mock_signin', to: 'mock_sessions#new'
  end

  ################
  ### Tracking ###
  ################

  get '/confirmation/:email_tracker_recipient_uid', :to => 'email_tracker_recipients#confirmation', :as => :confirmation
end
