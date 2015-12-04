require 'typhoeus'
require 'json'

module NanoTwitter
    @@base_url = "http://teamab.herokuapp.com"
    @@base_url = "http://127.0.0.1:4567"

    def self.parse(response)
        if response.code == 200
            JSON.parse(response.body)
        elsif response.code == 404
            nil
        else
            raise response.body
        end
    end

    def self.getTimeline(user_id)
        url = user_id.nil? ? "#{@@base_url}/api/v1/tweets/recent" : "#{@@base_url}/api/v1/users/#{user_id}/tweets"
        response = Typhoeus::Request.get(url)
        parse(response)
    end

    def self.getUser(id)
        response = Typhoeus::Request.get("#{@@base_url}/api/v1/users/#{id}")
        parse(response)
    end

    def self.getTweet(id)
        response = Typhoeus::Request.get("#{@@base_url}/api/v1/tweets/#{id}")
        parse(response)
    end

end
