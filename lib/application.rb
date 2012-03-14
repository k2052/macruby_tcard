require 'rubygems' # disable this for a deployed application
require 'hotcocoa'  
 
# Load Windows     
Dir.glob("lib/*.rb").each do |file|
  require file
end    

class TCard
  include HotCocoa

  def start          
    application name: 'TCard' do |app| 
      app.delegate = self 
      MainWindow.new     
    end
  end   
end

TCard.new.start