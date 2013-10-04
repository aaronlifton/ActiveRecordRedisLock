if defined?(Redis) && Redis.try(:current).respond_to?(:lock)
  module ActiveRecordRedisLock
    def redis_lock(ob, action_name, options = {}, &blk)
      options = {life: 1}.merge!(options)
      klass = ob.class.name
      caller = if ob.superclass == ActiveRecord::Base 
        ob.try(:id)
      else
        ob.to_s
      end

      Redis.current.lock("#{klass}.#{caller || 'anon'}.#{action_name}", options) do 
        blk.call(self)
        # logger.debug("redis_locked called @ #{Time.now.to_i}") if debug
      end
    end
  end
end

ActiveRecord::Base.extend(ActiveRecordRedisLock)
