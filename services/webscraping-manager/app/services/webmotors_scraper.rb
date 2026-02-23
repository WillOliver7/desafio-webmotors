class WebmotorsScraper
  def self.call(page, task)
    task.update(status: 'processing')
    
    begin
      puts "🕵️ Iniciando coleta de dados..."
      h1 = page.locator("#VehicleBasicInformationTitle")
      
      text = h1.text_content&.strip
      model = h1.locator("strong").text_content&.strip
      description = h1.locator("#VehicleBasicInformationDescription").text_content&.strip
      price = page.locator("#vehicleSendProposalPrice").text_content&.strip

      brand = text.gsub(model, "").gsub(description, "").strip

      puts "🏎️ Marca: #{brand}"
      puts "🚘 Modelo: #{model}"

      data = {
        brand: brand,
        model: model,
        price: price
      }

      puts "✅ Dados coletados: #{data}"

      task.update!(
        result: data,
        status: 'completed',
        concluded_at: Time.current,
        title: "Coleta: #{data[:marca]} #{data[:modelo]}"
      )
      
    rescue => e
      puts "❌ Erro no Scraper: #{e.message}"
      task.update(status: 'failed', error_message: e.message)
    end
  end
end