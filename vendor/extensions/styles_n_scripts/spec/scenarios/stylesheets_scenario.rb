class StylesheetsScenario < Scenario::Base

  def load
    create_stylesheet "main", :content => "Main stylesheet content"
  end


  helpers do

    def create_stylesheet(filename, attributes={})
      create_model :stylesheet, 
                    filename.symbolize,
                    stylesheet_params(
                        attributes.reverse_merge(:filename => filename) )
    end


    def stylesheet_params(attributes={})
      filename = attributes[:filename] || unique_stylesheet_filename
      { 
        :filename => filename,
        :content => "stylesheet content for #{filename}"
      }.merge(attributes)
    end


    # the built-in scenario helper methods only deal with the root class (i.e.
    # the one with the table -- text_asset).  So we just build our own versions.
    #
    # NOTE: There must be no symbolic naming conflics between child classes (so
    # the Stylesheets scenario and Javascripts scenario can't both have a :main
    # That's ok since we're using :main_css and :main_js naming rules here.
    def stylesheets(symbolic_name)
      text_assets(symbolic_name)
    end


    def stylesheet_id(symbolic_name)
      text_asset_id(symbolic_name)
    end


    private

      @@unique_stylesheet_filename_call_count = 0

      def unique_stylesheet_filename
        @@unique_stylesheet_filename_call_count += 1
        "stylesheet-#{@@unique_stylesheet_filename_call_count}.css"
      end

  end

end