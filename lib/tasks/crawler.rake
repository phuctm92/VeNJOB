require 'open-uri'

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

      cities_name  = get_details_by_span(job_url, "Nơi làm việc: ").split(", ")
      industries   = get_details_by_span(job_url, "Ngành nghề: ").split(", ")
      level        = get_details_by_span(job_url, "Cấp bậc: ")
      salary       = get_details_by_span(job_url, "Lương: ")
      exp          = get_details_by_span(job_url, "Kinh nghiệm: ")
      end_at       = get_details_by_span(job_url, "Hết hạn nộp: ")

      description = ''
      job_url.css('.MarBot20').children.map do |element| 
        element.remove_attribute('class')
        description << element.to_html
      end

      import_data(title, description, salary, end_at, exp, level, company_name, company_addr, industries, cities_name)
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

  def get_details_by_span(url, sections_label)
    content = url.css("p:has(span:contains('#{sections_label}'))").children
    return "" if content.blank?
    content.shift
    content.text.gsub("\r\n",' ').split(' ').join(' ')
  end

  def import_data(title, description, salary, end_at, exp, level, company_name, company_addr, industries, cities_name)
    company = Company.find_or_create_by(name: company_name, address: company_addr)
    cities_name.each do |c|
      city = City.find_by(name: c)
      job = Job.create!(title:      title,      description:  description, 
        salary:     salary,     end_at:       end_at, 
        experience: exp,        level:        level, 
        company_id: company.id, city_id:      city.id)
      industries.each do |ind|
        job.industries << Industry.find_or_create_by!(name: ind)
      end          
    end
  end
end
