class MarchexCallRecord < ActiveRecord::Base
  belongs_to :client

  validates_uniqueness_of :marchex_call_id, scope: :client_id

  def self.get_client_records_for_period(client, start_datetime, end_datetime)

    basic_auth = { username: 'icarusreportingnetsearchdirect@gmail.com',
             password: 'ninetofivers72!marchex' }

    headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }

    body = { jsonrpc: '2.0',
             id: 1,
             method: 'call.search',
             params: [ client.marchex_id,
                       { start: start_datetime.iso8601,
                         end: end_datetime.iso8601,
                         exact_times: true,
                         extended: true } ]
           }.to_json

    response = HTTParty.post('https://userapi.voicestar.com/api/jsonrpc/1',
                  headers: headers,
                  basic_auth: basic_auth,
                  body: body )

    results = response.parse_response["result"]
  end
end
