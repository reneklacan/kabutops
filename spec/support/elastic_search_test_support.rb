module ElasticSearchTestSupport
  extend self

  ES_HOST = 'localhost'
  ES_PORT = '9200'
  ES_INDEX = 'kabutops_test'
  ES_TYPE = 'test'

  def create record
    client.index(
      index: ES_INDEX,
      type: ES_TYPE,
      id: record[:id],
      body: record.to_hash,
    )
    flush
  end

  def count
    flush
    client.count(index: ES_INDEX)['count']
  end

  def delete_all
    if index_exists?
      client.delete_by_query(index: ES_INDEX, body: { query: { match_all: {} } })
    else
      create_index
    end
  end

  def flush
    client.indices.flush
  end

  def create_index
    client.indices.create(index: ES_INDEX)
  end

  def index_exists?
    client.indices.exists(index: ES_INDEX)
  end

  def client
    @client ||= Elasticsearch::Client.new(
      hosts: [
        {
          host: ES_HOST,
          port: ES_PORT,
        },
      ],
    )
  end
end
