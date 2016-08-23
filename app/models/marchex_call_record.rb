class MarchexCallRecord < ActiveRecord::Base
  belongs_to :client

  validates_presence_of :marchex_call_id
  validates_uniqueness_of :marchex_call_id, scope: :client_id

  default_scope { order(:start_time) }

  # this should be on the client as well
  def self.get_client_records_for_period(client, start_datetime, end_datetime)

    puts "\nRequesting Marchex Call Records for #{client.name} - #{start_datetime} to #{end_datetime}"
    response = self.api_request('call.search',
                                [ client.marchex_account_id,
                                  { start: start_datetime.iso8601,
                                    end: end_datetime.iso8601,
                                    exact_times: true,
                                    extended: true } ] )
    puts "\tAPI request complete."

    puts "\tInitializing records..."
    call_records = response.parsed_response["result"].map do |api_result|
      call_record = client.marchex_call_records
                    .where(marchex_call_id: api_result['call_id'])
                    .first_or_initialize
      call_record.caller_name =         api_result['caller_name']
      call_record.caller_number =       api_result['caller_number']
      call_record.start_time =          Time.zone.parse(api_result['call_start'])
      call_record.campaign =            api_result['c_name']
      call_record.group_name =          api_result['g_name']
      call_record.duration =            api_result['call_duration']
      call_record.pretty_duration =     api_result['duration']
      call_record.dna_classification =  api_result['dna_class']
      call_record.status =              api_result['call_status']
      call_record
    end
    puts "\tRecords initialized."

    self.get_and_assign_playback_urls(call_records)

    puts "\tSaving records..."
    self.transaction do
      call_records.each(&:save!)
    end
    puts "\tRecords saved."
    puts "Marchex Call Records request complete.\n\n"
    client
  end

  def self.api_request(method, params)
    HTTParty.post(
      'https://userapi.voicestar.com/api/jsonrpc/1',
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' },
      basic_auth: { username: ENV['MARCHEX_USERNAME'],
                    password: ENV['MARCHEX_PASSWORD'] },
      body: { jsonrpc: '2.0', id: 1, method: method, params: params }.to_json
    )
  end


  def self.get_and_assign_playback_urls(call_records)

    counter = 1
    puts "\tSlicing records."
    call_records.map(&:marchex_call_id).each_slice(150) do |records_slice|

      puts "\tMaking playback-url API request for slice #{counter}..."
      response = self.api_request('call.audio.url', [records_slice, 'mp3'])

      response.parsed_response['result'].each do |api_result|
        selected_record = call_records.find do |record|
          record.marchex_call_id == api_result['call_id']
        end
        selected_record.playback_url = api_result['url']
      end
      puts "\tCompleted playback-url API request for slice #{counter}."

      counter += 1

    end
  end
end
