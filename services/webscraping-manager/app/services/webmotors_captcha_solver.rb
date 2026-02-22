require 'playwright'
class WebmotorsCaptchaSolver
  def self.run(task_id)
    task = Task.find(task_id)

    ::Playwright.connect_to_browser_server("ws://playwright:3000/playwright?stealth=true&--headless=false") do |browser|
      context = browser.new_context(
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        viewport: { width: 1366, height: 768 }
      )
      page = context.new_page
      page.add_init_script(script: "delete Object.getPrototypeOf(navigator).webdriver;")

      puts "🚀 Acessando anúncio: #{task.url}"
      page.goto(task.url, waitUntil: 'load')

      captcha_element = page.locator('#px-captcha')

      retries = 0      
      if captcha_element.count > 0
        begin
          puts "👾 Captcha detectado. Analisando posição..."
          captcha_element.scroll_into_view_if_needed
          sleep rand(1..2)
          box = captcha_element.bounding_box

          target_x = box['x'] + (box['width'] / 2)
          target_y = box['y'] + (box['height'] / 2)
          
          puts "🖱️ Movendo mouse em arco até o alvo..."
          page.mouse.move(target_x - 50, target_y + 30)
          sleep rand(0.5..1.5)
          page.mouse.move(target_x, target_y)

          puts "👆 Pressionando e segurando..."
          page.mouse.down
          
          5.times do |i|
            page.wait_for_timeout(1500)
            page.mouse.move(target_x + (i % 2), target_y + (i % 2))
            puts "⏳ Mantendo pressão... (#{i+1}/5)"
          end
          
          page.mouse.up
          puts "✅ Botão solto!"
          puts "⏳ Aguardando resposta do captcha..."
          sleep 10

          captcha_element = page.locator('#px-captcha')
          if captcha_element.count > 0
            puts "❌ Falhou. O captcha ainda está lá."
            raise "Captcha não resolvido"
          else
            puts "🎉 Sucesso! A página parece ter liberado."
            WebmotorsScraper.call(page, task)
          end          
        rescue
          retries += 1
          if retries < 5
            puts "⚠️ Tentativa #{retries} falhou. Retentando..."
            retry
          end
          task.update(status: 'failed', error_message: "Não conseguiu vencer o Captcha após tentativas.") if retries >= 5
        end
      else
        puts "🤷 Captcha não apareceu desta vez."
        WebmotorsScraper.call(page, task)
      end
    end
  rescue => e
    Task.find(task_id).update(status: 'failed', error_message: e.message)
    puts "💥 Erro: #{e.message}"
  end
end