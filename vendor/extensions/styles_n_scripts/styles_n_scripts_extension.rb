# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

# allows admins to customize settings for the extension:
include CustomSettings


class StylesNScriptsExtension < Radiant::Extension
  version "0.4.1"
  extension_name "Styles 'n Scripts"
  description "Adds CSS and JS file management to Radiant"


  define_routes do |map|
    # Admin stylesheet Routes
    map.with_options(:controller => 'admin/text_asset', :asset_type => 'stylesheet') do |controller|
      controller.stylesheet_index   'admin/css',              :action => 'index'
      controller.stylesheet_edit    'admin/css/edit/:id',     :action => 'edit'
      controller.stylesheet_new     'admin/css/new',          :action => 'new'
      controller.stylesheet_remove  'admin/css/remove/:id',   :action => 'remove'
      controller.stylesheet_upload  'admin/css/upload',       :action => 'upload'
    end
    
    # Admin javascript Routes
    map.with_options(:controller => 'admin/text_asset', :asset_type => 'javascript') do |controller|
      controller.javascript_index   'admin/js',               :action => 'index'
      controller.javascript_edit    'admin/js/edit/:id',      :action => 'edit'
      controller.javascript_new     'admin/js/new',           :action => 'new'
      controller.javascript_remove  'admin/js/remove/:id',    :action => 'remove'
      controller.javascript_upload  'admin/js/upload',        :action => 'upload'
    end

    # Public side routes (for JS and CSS directories)
    map.connect "#{StylesNScripts::Config[:stylesheet_directory]}/*filename",
                :controller => 'text_asset_site', :action => 'show_text_asset',
                :directory => StylesNScripts::Config[:stylesheet_directory],
                :asset_type => 'stylesheet'

    map.connect "#{StylesNScripts::Config[:javascript_directory]}/*filename",
                :controller => 'text_asset_site', :action => 'show_text_asset',
                :directory => StylesNScripts::Config[:javascript_directory],
                :asset_type => 'javascript'
  end


  def activate
    admin.tabs.add "CSS", "/admin/css", :after => "Layouts", :visibility => [:admin, :developer]
    admin.tabs.add "JS", "/admin/js", :after => "CSS", :visibility => [:admin, :developer]

    Page.send :include, ExtendedPageTags

    # join already observed models with extension models 
    observables = UserActionObserver.instance.observed_classes | [Stylesheet, Javascript] 

    # update list of observables 
    UserActionObserver.send :observe, observables 

    # connect UserActionObserver with my models 
    UserActionObserver.instance.send :add_observer!, Stylesheet 
    UserActionObserver.instance.send :add_observer!, Javascript 

    # activate TextAssetObserver (can't be set via config.active_record.observer)
    TextAssetObserver.instance.send :add_observer!, Stylesheet
    TextAssetObserver.instance.send :add_observer!, Javascript
  end 


  def deactivate
    admin.tabs.remove "CSS"
    admin.tabs.remove "JS"
  end

end