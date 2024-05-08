#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'aws-sdk-s3'

def handler(event:, context:)
  bucket_name = 'orn.intermittent.energy'
  uri = URI('http://tr.ons.org.br/Content/GetBalancoEnergetico/null')

  res = Net::HTTP.get_response(uri)
  json = JSON.parse(res.body)
  object_key = json['Data'].gsub(/T/,'/')+".json"
  object = Aws::S3::Object.new(bucket_name, object_key)
  object.put(body: res.body)
end
#handler(event:nil, context:nil)
