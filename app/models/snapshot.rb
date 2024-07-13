require 'mail'

class Snapshot < ApplicationRecord
  serialize :data, coder: JSON

  def self.take
    connection = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)

    nodes = Set[]
    links = []

    total_messages = connection.get_messages_count
    messages = connection.get_messages(count: total_messages, offset: 0) 
    
    messages.each do |message|
      sources = []
      message[:to].each do |to|
        source = to["Name"]
        sources << source
        nodes = addNode(nodes, source)
      end

      target = extract_address(message[:from])
      nodes = addNode(nodes, target)

      topic = message[:subject]

      sources.each do |source|
        links = addLink(links, source, target, topic)
      end

    end

    data = {
      nodes: nodes.to_a,
      links: links
    }

    Snapshot.new(data: data)
  end

  def self.addNode(nodes, id)
    nodes.add({
      id: id
    })
  end

  def self.addLink(links, source, target, topic)
    item_index = links.index{ |x| x[:source] == source && x[:target] == target }
    if item_index.blank?
      item = {
        source: source,
        target: target,
        topics: [topic]
      }
      links << item
    else
      links[item_index][:topics] << topic
    end
    links
  end

  def self.extract_address(address_string)
    Mail::Address.new(address_string).display_name
  end
end


