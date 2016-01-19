module Fluent
  class JsonToRdsOutput < BufferedOutput
    Plugin.register_output('json_to_rds', self)

    # change db_name
    TD_TAG = "td.db_name."
    attr_reader :child_queue

    def emit(tag, es, chain)
      chain.next

      table = tag.split('.')[-1]
      @child_queue = Queue.new
      output = self.class.new

      es.each do |time, record|
        record_hash = (Digest::SHA256.hexdigest (record.to_s+Time.now.to_s)).hex
        Engine.emit(TD_TAG + table, time, parse(record, [], table, record_hash))

        until @child_queue.empty?
          child = @child_queue.pop
          output.emit(child[:table], OneEventStream.new(time, child[:record]), chain)
        end
      end
    end

    private
    def parse(record, prefix, table, record_hash)
      ret = {}
      if record.is_a? Hash
        record.each do |k, v|
          ret.merge!(parse(v, prefix + [k.to_s], table, record_hash))
        end
      elsif record.is_a? Array
        child_table = ([table.split('.')]+prefix).join('_')
        record.each_with_index do |v, i|
          @child_queue.push({table:child_table, record:{"#{table}_hash"=>record_hash, "#{child_table}_index"=>i, (prefix[-1]||'array')=>v}})
        end
        return {"#{table}_hash" => record_hash}
      else
        return {prefix.join('_') => record}
      end
      ret
    end
  end
end
