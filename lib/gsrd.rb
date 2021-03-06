module Gsrd
    
    if ARGV.empty?
        
        begin
            raise ArgumentError
        rescue Exception => ex
            puts "\nERROR: You must provide your access_token.\nCheck it out @ https://github.com/LeonardoCardoso/gsrd#getting-your-credential\n\n"
        end

        exit

    end
    
    class Download
        
        require "httparty"
        
        $base_uri = "https://api.github.com"
        $repos_uri = $base_uri + "/user/starred?per_page=100&access_token="
        $archive = "/archive/"
        $extension = ".zip"
        $page = "&page="
        
        def initialize(token)
            @token = token
        end
        
        def go()
            
            @time = Time.new
            @month = @time.month.to_s.rjust(2, "0")
            @day = @time.day.to_s.rjust(2, "0")
            @directory_name = Dir.pwd + "/gsrd-downloads-#{@time.year}-#{@month}-#{@day}"
            Dir.mkdir(@directory_name) unless File.exists?(@directory_name)
            
            @pagination = 1
            @count = 0
            
            loop do
                
                response = HTTParty.get($repos_uri + @token + $page + "#{@pagination}")
                
                for repo in response.parsed_response
                    
                    @uri = repo["html_url"]
                    @download_uri = @uri + $archive + repo["default_branch"] + $extension
                    @file_name = repo["owner"]["login"] + "-" + repo["name"] + "-" + repo["default_branch"] + $extension
    
                    puts "\n\n======= DOWNLOADING " + repo["name"] + " ======= "
                    puts "URL: " + @uri
                    puts "Download URL: " + @download_uri
                    puts "started: " + Time.now.strftime("%d/%m/%Y %H:%M:%S")
                    
                    @wget = "wget -O " + @directory_name + "/" + @file_name + " " + @download_uri + " -q --show-progress"
                    
                    `#{@wget}`
                    
                    puts "finished: " + Time.now.strftime("%d/%m/%Y %H:%M:%S")
                    
                    @count += 1
                
                end

                @pagination += 1
            
                break if response.parsed_response.count == 0
            
            end
            
            puts "\n\n======= #{@count} repos were downloaded to gsrd-downloads directory =======\n\n"

        end
        
    end
    
    gsrd = Download.new(ARGV[0])
    gsrd.go()
    
end
