#!/usr/bin/env ruby
require 'bundler/setup'
require 'faraday'
require 'fastest_csv'
require 'aws-sdk-dynamodb'
ENV['TZ'] = 'UTC'

module Aeso
  class SupplyDemand
    def fetch
      url = "http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet?contentType=csv"
      res = Faraday.get(url)

      chunks = res.body.split("\r\n\r\n")
      chunks[1] =~ /Last Update : (.*)/
      @time = Time.strptime($1, "%b %d, %Y %H:%M")

      #SUMMARY
      csv = FastestCSV.parse chunks[2]
      raise unless csv[2][0] == 'Alberta Internal Load (AIL)'
      @load = csv[2][1].to_i

      #GENERATION
      csv = FastestCSV.parse chunks[3]
      @r_gen = []
      csv.each do |row|
        production_type = row[0]
        value = row[2].to_i
        @r_gen << {production_type:, value:}
      end

      #INTERCHANGE
      csv = FastestCSV.parse chunks[4]
      @r_trans = []
      csv.each do |row|
        area = row[0]
        value = row[1].to_i
        @r_trans << {area:, value:}
      end

      #UNITS GROUPED BY FUEL
      @r_units = []
      chunks[5..].each do |chunk|
        csv = FastestCSV.parse chunk
        csv.each do |row|
          next unless row[0] =~ /\((.*)\)/
          unit_id = $1
          value = row[2].to_i
          @r_units << {unit_id:, value:}
        end
      end
    end
    def to_json
      {
        time: @time.to_i,
        generation: @r_gen,
        units: @r_units,
        transmission: @r_trans
      }
    end
    def store
      client = Aws::DynamoDB::Client.new(region: "us-east-2")
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table('aeso')
      @table.put_item(item: to_json)
    end
  end
end

def handler(event:, context:)
  a = Aeso::SupplyDemand.new
  a.fetch
  a.store
end
#handler(event:nil, context:nil)
