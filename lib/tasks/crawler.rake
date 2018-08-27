require 'open-uri'
require 'nokogiri'

namespace :crawler do

  desc "get job"
  task get_jobs: :environment do
    page = Nokogiri::HTML(open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-vi.html"))

    page.css('h3.job a').map do |link| 
      job_url = Nokogiri::HTML(open(URI.parse(URI.encode(link['href']))))

      title = job_url.css('.top-job-info h1').text
      next if title.blank? #skip link having different format

      company_name = job_url.css('.top-job-info').css('.tit_company').text
      company_addr = job_url.css('p.TitleDetailNew').css('label label').text

      city_name = job_details(job_url, "Nơi làm việc: ").split(", ")
      industry  = job_details(job_url, "Ngành nghề: ")
      level     = job_details(job_url, "Cấp bậc: ")
      salary    = job_details(job_url, "Lương: ")
      exp       = job_details(job_url, "Kinh nghiệm: ")
      end_at    = job_details(job_url, "Hết hạn nộp: ")

      description = ''
      job_url.css('.MarBot20').children.map do |element| 
        element.remove_attribute('class')
        description << element.to_html
      end

      company = Company.find_or_create_by(name: company_name, address: company_addr)
      city_name.each do |c|
        city = City.find_by(name: c)
        Job.create!(title: title, description: description, salary: salary,
          end_at: end_at, experience: exp, level: level, company_id: company.id, city_id: city.id)
      end

      puts URI.parse(URI.encode(link['href']))
      puts "#{title}"
      puts "#{salary}" 
      puts "#{level}"
      puts "#{end_at}"
      puts "#{city_name}"
      puts "#{company_name} : #{company_addr}"
      puts '-------------------------'
    end
  end


  task get_cities: :environment do
    page = Nokogiri::HTML(open("https://careerbuilder.vn/vi/"))
    cities = page.css('select#location2 option').map {|c|  c.text}
    cities.shift
    cities.each {|c| City.create(name: c)}
  end

  task get_industries: :environment do
    page = Nokogiri::HTML(open("https://careerbuilder.vn/vi/"))
    industries = page.css('select#industry2 option').map {|c| c.text}
    industries.shift
    industries.each { |i| Industry.create(name: i) }
  end

  def job_details(url, sections_label)
    content = url.css("p:has(span:contains('#{sections_label}'))").children
    return "" if content.blank?
    content.shift
    content.text.gsub("\r\n",' ').split(' ').join(' ')
  end
end
