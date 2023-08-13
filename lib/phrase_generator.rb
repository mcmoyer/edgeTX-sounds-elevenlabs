# frozen_string_literal: true

require 'csv'
require 'net/http'
require 'pathname'
require 'uri'

ELEVEN_LABS_API_KEY=ENV['ELEVEN_LABS_API_KEY']

EdgeTXSound = Struct.new(:path, :filename, :text, :translation)

class PhraseGenerator
  
  def initialize(voice_id:, destination:, csv:)
    @destination = destination
    @csv = csv
    @voice_id = voice_id
    @sounds = nil
    unless Pathname(@csv).exist?
      puts "unable to location csv file #{@csv}"
      exit(1)
    end
  end

  def import_csv_rows
      header_downcase = -> { _1.downcase }
      csv = CSV.read(@csv, skip_blanks: true, headers: true, header_converters: header_downcase)
      @sounds = csv.map { EdgeTXSound.new(_1['path'], _1['filename'], _1['source text'], _1['translation']) }
  end

  def destination_paths
    @sounds.map(&:path).uniq.reject(&:empty?)
  end

  def make_destination_paths
    Pathname(@destination).mkpath
    destination_paths.each do |path|
      (Pathname(@destination) + path).mkpath
    end
  end

  def retrieve_sound_from_elevenlabs(sound)
    payload = <<~EOF
      {
        "text": "#{sound.text}", 
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {
          "stability": 0.5,
          "similarity_boost": 0.5
        }
      }
    EOF

    uri = URI.parse("https://api.elevenlabs.io/v1/text-to-speech/#{@voice_id}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "audio/mpeg"
    request["Xi-Api-Key"] = ELEVEN_LABS_API_KEY
    request.body = payload
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response.body if response.code.to_i >= 400
    # return the binary response
    response.body
  end

  def generate_sounds
    @sounds.each do |sound|
      output_path = Pathname(@destination) + sound.path + sound.filename
      puts "creating sound '#{sound.translation}' to #{output_path}"
      next if Pathname(output_path).exist?

      temp_path = Pathname(output_path).sub_ext(".mp3")
      Pathname(temp_path).binwrite(retrieve_sound_from_elevenlabs(sound))

      convert_to_RM_format(temp_path, output_path)
      Pathname(temp_path).delete
    end
  end

  def convert_to_RM_format(from_file, to_file)
    convert_command = %Q|afconvert -f WAVE -d LEI16@32000 -c 1 "#{from_file}" "#{to_file}"|
    puts convert_command
    `#{convert_command}`
  end

  def process
    import_csv_rows
    make_destination_paths
    generate_sounds
  end
end



  #`say -v "#{VOICE}" -o "#{full_path}" --channels=1 --data-format=LEI16@32000 "#{row['source text']}"`
#end
