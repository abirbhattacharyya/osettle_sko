ActionController::Routing::Routes.draw do |map|
  map.root :controller => "home"

  map.biz '/biz', :controller => 'users', :action => 'biz'
  map.login '/login', :controller => 'users', :action => 'login'
  map.logout '/logout', :controller => 'users', :action => 'destroy'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'

  map.agree '/agree', :controller => 'users', :action => 'agree'
  map.terms '/terms', :controller => 'users', :action => 'terms'
  map.verify '/verify', :controller => 'users', :action => 'verify'
  map.congratulations '/congratulations', :controller => 'home', :action => 'complete_payment'

  map.negotiate '/negotiate', :controller => 'users', :action => 'negotiate'
  map.schedule '/schedule/:id', :controller => 'users', :action => 'schedule'
  map.payment '/payment/:pt/:id', :controller => 'users', :action => 'payment'

  map.analytics '/analytics', :controller => 'home', :action => 'analytics'
  map.reports '/reports', :controller => 'home', :action => 'reports'
  map.notifications '/notifications', :controller => 'home', :action => 'notifications'
  map.view_data '/view_data', :controller => 'home', :action => 'view_data'
  map.daily_report '/daily_report', :controller => 'home', :action => 'daily_report'
  map.daily_payment_report '/daily_payment_report', :controller => 'home', :action => 'daily_payment_report'
  
  map.faq '/faq', :controller => 'home', :action => 'faq'
  map.privacy '/privacy', :controller => 'home', :action => 'privacy'
  
  map.profile '/profile', :controller => 'users', :action => 'profile'
  map.upload_option '/upload_option', :controller => 'users', :action => 'upload_option'
  map.profile_logo '/profiles/:id/logos', :controller => 'users', :action => 'profile_logo'
  
  map.feeds '/feeds', :controller => 'users', :action => 'feeds'
  map.manual_feed '/manual_feed', :controller => 'users', :action => 'manual_feed'
  map.verify_user '/authenticate/:id/:key', :controller => 'users', :action => 'verify_user'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
