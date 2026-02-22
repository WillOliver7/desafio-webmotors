class ScrapeVehiclesWorker
  include Sidekiq::Worker

  def perform(url)
    task = Task.create!(
      url: url,
      title: "BMW X2 - Pendente"
    )
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