module Fluent
  class TextParser
    class JsonFlatter < Parser
      Plugin.register_parser('json_flatter', self)

      def parse(text)
        json_hash = JSON.parse(text)
        return Engine.now, JSON.generate(flatter(json_hash))
      end

      def flatter(json_hash, prefix='')
        result = {}
        json_hash.each do |k, v|
          # 親のキーと結合する
          full_key = prefix + k.to_s

          # ネストしている場合は再起する
          if v.kind_of?(Enumerable)
            # 配列をハッシュに変換する(キーは1から始める)
            if v.kind_of?(Array)
              hash_v = {}
              v.length.times do |i|
                hash_v[i+1] = v[i]
              end
              v = hash_v
            end
            # 子要素を渡して再起
            result = result.merge(flatter(v, full_key+'.'))
          else
            result[full_key] = v
          end
        end
        result
      end
    end
  end
end
