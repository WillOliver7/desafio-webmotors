class ScrapeVehiclesWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = Task.find(task_id)
    url = task.url
    puts "🚀 Iniciando scraping para: #{url}"
    WebmotorsCaptchaSolver.run(task.id)
    
    if task.reload.status == 'failed'
      puts "❌ Falha ao resolver captcha para: #{url}"
      # No futuro: Notificar o NotificationServiceClient aqui!
      puts "Scraping finalizado para: #{url}"
    else
      puts "✅ Scraping concluído para: #{url}"
      # No futuro: Notificar o NotificationServiceClient aqui!
      puts "Scraping finalizado para: #{url}"
    end
  end
end