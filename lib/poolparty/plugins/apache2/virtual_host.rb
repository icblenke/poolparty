require File.dirname(__FILE__)+'/apache'
module PoolParty
  module Plugin
    class VirtualHost < Plugin
      def listen(port="80")
        has_variable(:name => "port", :value => port)
        port port
      end

      def virtual_host_entry(file)
        @virtual_host_entry = true
        if ::File.file?(file)
          has_file(dsl_options.merge({:name => "/etc/apache2/sites-available/#{name}", 
                                  :template => file, 
                                  :requires => get_package("apache2")}))
        else
          has_file(dsl_options.merge({:content => file, 
                                  :name => "/etc/apache2/sites-available/#{name}", 
                                  :requires => get_package("apache2")}))
        end
      end


      def loaded(opts={}, parent=self)
        has_directory(:name => "/var/www", :owner => www_user, :mode=>'0744')
        has_directory(:name => "/var/www/#{name}", :owner => www_user, :mode=>'0744')
        has_directory(:name => "/var/www/#{name}/logs", :owner => www_user, :mode=>'0744')

        has_variable(:name => "sitename", :value => "#{name}")

        unless @virtual_host_entry
          virtual_host_entry <<-eof
  <VirtualHost *:#{port}> 
  ServerName     #{name}
  DocumentRoot   /var/www/#{name}
  </VirtualHost>
  eof
        end

        has_exec(:name => "insert-site-#{name}", 
                 :command => "/usr/sbin/a2ensite #{name}", 
                 :calls => get_exec("reload-apache2"), 
                 :requires => get_file("/etc/apache2/sites-available/#{name}")) do
          requires get_package("apache2")
          if_not "/bin/sh -c '[ -L /etc/apache2/sites-enabled/#{parent.name} ] && [ /etc/apache2/sites-enabled/#{parent.name} -ef /etc/apache2/sites-available/#{parent.name} ]'"
        end
      end
      
    end
    
  end
  
end