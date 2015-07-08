# name: discourse-heap
# about: Log requests that affect the heap size
# version: 0.1
# author: Robin Ward

require 'logger'

class HeapMiddleware
  def initialize(app)
    @app = app
    @logger = Logger.new('/tmp/gc.heaps.log')
  end

  def call(env)
    before = GC.stat
    result = @app.call(env)
    after = GC.stat

    heap_diff = (after[:heap_used] || 0) - (before[:heap_used] || 0)

    if heap_diff > 100
      qp = env['QUERY_STRING']
      qp = qp.present? ? "?#{qp}" : ""
      @logger.info("#{env['REQUEST_METHOD']} #{env['REQUEST_PATH']}#{qp} #{heap_diff}\n")
    end

    result
  end
end

Rails.application.middleware.use HeapMiddleware
