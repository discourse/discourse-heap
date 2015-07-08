# name: discourse-heap
# about: Log requests that affect the heap size
# version: 0.1
# author: Robin Ward

require 'logger'

class HeapMiddleware
  def initialize(app)
    @app = app
    @logger = Logger.new('/tmp/gc.slots.log')
  end

  def call(env)
    before = GC.stat
    result = @app.call(env)
    after = GC.stat

    slot_diff = (after[:heap_live_slots] || 0) - (before[:heap_live_slots] || 0)

    if slot_diff > 100
      qp = env['QUERY_STRING']
      qp = qp.present? ? "?#{qp}" : ""
      @logger.info("#{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}#{qp} #{slot_diff}\n")
    end

    result
  end
end

Rails.application.middleware.use HeapMiddleware
