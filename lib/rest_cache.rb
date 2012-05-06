require "rest_cache/version"

module RestCache
	
	class Middleware

		EXPIRATION_SECONDS_DEFAULT = 300
		GLOBAL_CACHING_DEFAULT = true

	  @@cache = {}
	
	  def initialize(app, options)
	  
	  	# assign defaults to potentially missing options
	    options[:expiration_seconds] ||= EXPIRATION_SECONDS_DEFAULT
	    options[:global] &&= GLOBAL_CACHING_DEFAULT
	  
	    @app = app
	    @options = options
	  end
	
	  def call(env)
	
    	@request = Rack::Request.new(env)

	    if @request.get?
	      get(env)
	    else
	      # expire all cached items for this request
	      expire(@request.fullpath.gsub(/\.(.*)$/, '')) # strip the format, if present
	
	      # pass along the call
	      @app.call(env)
	    end
	
	  end
	  
	  def expire(path=nil)
	    if path
	      purge_path path
	    else
	      purge_all
	    end
  	end

	  def self.expire(path=nil)
	    if path
	      purge_path path
	    else
	      purge_all
	    end
  	end

  	private

  	def get(env)

    	purge_expired

	    # build a key out of this request
	    key = ''
    	key << @request.session[:session_id].to_s unless @options[:global] 
    	key << @request.fullpath
    
	    # return the cached result, if present
	    if @@cache.has_key? key
	      @@cache[key][:data]
	    else
	      # otherwise, cache it
	      @@cache[key] = { :expires_at => Time.now + @options[:expiration_seconds].seconds,
	                       :data => @app.call(env) }
	      @@cache[key][:data]
	    end
  	end

	  def purge_path(path)
	    @@cache.each do |key, value|
	      @@cache.delete(key) if key.gsub(/\.(.*)$/, '').end_with? path
    	end
	  end

	  def purge_expired
    	# Cleaning cache
	    now = Time.now

	    @@cache.each do |key, value|
      	@@cache.delete(key) if value[:expires_at] < now
	    end
  	end

	  def purge_all
    	@@cache = {}
    end
  end
end
