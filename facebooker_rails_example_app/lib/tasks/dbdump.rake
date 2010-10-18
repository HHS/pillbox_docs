require 'find'

# rake db:fixtures:dump only='vehicle_production_run, vehicle_model, vehicle, turn, style, research_level, fund_research, drivetrain_proficiency, drivetrain, bank_transaction'

namespace :db do
  namespace :fixtures do
    desc 'Dumps all models into fixtures.'
    task :dump => :environment do
      models = []
      Find.find(RAILS_ROOT + '/app/models') do |path|
        unless File.directory?(path) 
          models << path.match(/(\w+).rb/)[1] rescue nil
        end
      end
      if File.directory?(RAILS_ROOT + '/vendor/plugins/acts_as_taggable_on_steroids')
        models += ['tag','tagging'] 
      end
      models = models.compact.uniq
      puts "Found models: " + models.join(', ')

      if ENV['only']
        required_models = ENV['only'].split(',').map{|m| m.strip.underscore }
        models = (models & required_models)         
        raise "can't find all of those models" unless (required_models - models).empty?
      end
      
      models -= ENV['except'].split(',').map{|m| m.strip.underscore }    if ENV['except']        
      puts "Using models: " + models.join(', ')

      models.each do |m|
#        begin
          puts "Dumping model: " + m
          model = m.camelize.constantize
          entries = model.find(:all, :order => 'id ASC')

          formatted, increment, tab = '', 1, '  '
          entries.each do |a|
            formatted += m + '_' + increment.to_s + ':' + "\n"
            increment += 1

            a.attributes.each do |column, value|
              formatted += tab

              match = value.to_s.match(/\n/)
              if match
                formatted += column + ': |' + "\n"

                value.to_a.each do |v|
                  formatted += tab + tab + v
                end
              else
                formatted += column + ': "' + value.to_s + '"'
              end

              formatted += "\n"
            end

            formatted += "\n"
          end

          model_file = RAILS_ROOT + '/test/fixtures/' + m.pluralize + '.yml'

          File.exists?(model_file) ? File.delete(model_file) : nil
          File.open(model_file, 'w') {|f| f << formatted}
#        rescue
#          puts "skipping #{m}"
#        end
      end


    end
  end
end