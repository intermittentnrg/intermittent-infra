#!/usr/bin/env ruby
require 'net/http'
require 'aws-sdk-sns'

URL = "http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet?contentType=csv"
def handler(event:, context:)
  res = Net::HTTP.get_response(URI(URL))
  sns = Aws::SNS::Resource.new
  topic = sns.topic(ENV['SNS_TOPIC'])

  topic.publish({message: res.body})
end
#handler(event:nil, context:nil)
