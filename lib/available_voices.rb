# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

class AvailableVoices
  VOICE_URL = "https://api.elevenlabs.io/v1/voices"
  def self.list
    uri = URI.parse(VOICE_URL)
    response = Net::HTTP.get_response(uri)

    voices = JSON.parse(response.body)['voices']

    puts "Voice ID             | Name            | Labels"
    puts "---------------------|-----------------|---------------------------------------------------------------------"
    voices.each { puts "#{_1['voice_id']} | #{_1["name"].ljust(15, " ")} | #{_1['labels']}" }
  end
end
