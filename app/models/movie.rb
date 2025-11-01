class Movie < ActiveRecord::Base

  # Replace your old find_in_tmdb method with this
  def self.find_in_tmdb(params, api_key = "7067fba6ce1a25112cce131f7dcd651f") # <-- PUT YOUR KEY HERE
    base_url = "https://api.themoviedb.org/3/search/movie"
    
    # Build the query parameters hash
    query_params = {
      api_key: api_key,
      query: params[:title],
      language: params[:language]
    }
    
    if params[:release_year].present?
      query_params[:year] = params[:release_year]
    end

    # Make the API call using Faraday
    begin
      response = Faraday.get(base_url, query_params)
    rescue Faraday::Error => e
      # Handle connection errors
      Rails.logger.error "Faraday error: #{e.message}"
      return []
    end

    # Parse the JSON response
    if response.success?
      results = JSON.parse(response.body)["results"]
      
      # If no results, return an empty array
      return [] if results.blank?

      # Map the results to NEW, UNSAVED Movie objects
      movies = results.map do |movie_data|
        Movie.new(
          title: movie_data["title"],
          release_date: movie_data["release_date"],
          rating: 'R', # Hardcode rating to 'R' as per spec
          description: movie_data["overview"]
        )
      end
      return movies
    else
      Rails.logger.error "TMDb API error: #{response.status} #{response.body}"
      return []
    end
  end

end