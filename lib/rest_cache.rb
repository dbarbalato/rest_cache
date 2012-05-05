require "rest_cache/version"

module RestCache

	class Middleware

	  @@cache = {}
	
	  def initialize(app, options = { :expiration_seconds => 300, :global => true })
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

	    # build a request
    	key = @request.fullpath
	    key << @request.session[:session_id] unless @options[:global]
    
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
	      @@cache.delete(key) if key.gsub(/\.(.*)$/, '') == path
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