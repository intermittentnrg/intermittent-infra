#!/usr/bin/env ruby
require 'bundler/setup'
require 'faraday'
require 'fast_jsonparser'
require 'aws-sdk-dynamodb'
ENV['TZ'] = 'UTC'

module Taipower
  class Generation
    def fetch
      url = 'https://www.taipower.com.tw/d006/loadGraph/loadGraph/data/genary_eng.json'
      res = Faraday.get(url)
      json = FastJsonparser.parse(res.body)

      @time = Time.strptime(json[:""], '%Y-%m-%d %H:%M')
      @r_gen = []
      @r_units = {}
      json[:dataset].each do |row|
        #0:fueltype
        row[0] =~ %r|<b>(.*)</b>|
        production_type = $1
        #1:blank
        #2:unit_id
        unit_id = row[2]
        #3:capacity
        #4:output
        value = (row[4].to_f*1000).to_i
        #output as % of capacity
        #remark
        #blank
        if unit_id.include? 'Subtotal'
          @r_gen << {production_type:, value:}
        else
          @r_units[unit_id] ||= {unit_id:, value: 0}
          @r_units[unit_id][:value] += value
        end
      end
      @r_units = @r_units.values
      #require 'pry' ; binding.pry
    end
    def to_json
      {
        time: @time.to_i,
        generation: @r_gen,
        units: @r_units,
      }
    end
    def store
      client = Aws::DynamoDB::Client.new(region: "ap-east-1")
      @dynamo_resource = Aws::DynamoDB::Resource.new(client: client)
      @table = @dynamo_resource.table('taipower')
      @table.put_item(item: to_json)
    end
  end
end

def handler(event:, context:)
  a = Taipower::Generation.new
  a.fetch
  #puts a.to_json
  a.store
end
#handler(event:nil, context:nil)
