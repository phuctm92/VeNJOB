require 'open-uri'

namespace :crawler do

  task :get_jobs  do
    cities     = get_value_from_dropdown("location2")
    industries = get_value_from_dropdown("industry2")

    page = Nokogiri::HTML(open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-vi.html"))

    data = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }
    id = 0
    page.css('h3.job a').map do |link|
      job_url = Nokogiri::HTML(open(URI.parse(URI.encode(link['href']))))

      data["job_#{id}".to_s][:title] = job_url.css('.top-job-info h1').text
      next if @data["job_#{id}".to_s][:title].blank?

      data["job_#{id}".to_s][:company_name] = job_url.css('.top-job-info').css('.tit_company').text
      data["job_#{id}".to_s][:company_addr] = job_url.css('p.TitleDetailNew').css('label label').text
      data["job_#{id}".to_s][:cities_name]  = get_details_by_span(job_url, "Nơi làm việc: ").split(", ")
      data["job_#{id}".to_s][:industries]   = get_details_by_span(job_url, "Ngành nghề: ").split(", ")
      data["job_#{id}".to_s][:level]        = get_details_by_span(job_url, "Cấp bậc: ")
      data["job_#{id}".to_s][:salary]       = get_details_by_span(job_url, "Lương: ")
      data["job_#{id}".to_s][:exp]          = get_details_by_span(job_url, "Kinh nghiệm: ")

      description = ''
      job_url.css('.MarBot20').children.map do |element| 
        element.remove_attribute('class')
        description << element.to_html
      end
      data["job_#{id}".to_s][:description] = description
      id += 1

      puts "#{link['href']}"
    end
  end


  def get_value_from_dropdown(id)
    page = Nokogiri::HTML(open("https://careerbuilder.vn/vi/"))
    datas = page.at("select##{id}").css('option').map(&:text)
    datas.shift
    datas
  end

  def get_details_by_span(url, sections_label)
    content = url.css("p:has(span:contains('#{sections_label}'))").children
    return "" if content.blank?
    content.shift
    content.text.gsub("\r\n",' ').split(' ').join(' ')
  end

  task import_data: :environment do
    Rake::Task["crawler:get_jobs"].invoke
    
    cities.each {|c| City.find_or_create_by(name: c) }
    industries.each {|i| Industry.find_or_create_by(name: i) }
    data.each do |key, value|
      company = Company.find_or_create_by(name: data.dig(key, :company_name)) do |c|
        c.address = data.dig(key, :company_addr)
      end
      
      data.dig(k, :cities_name).each do |c|
        city = City.find_by_name(c)
        job = Job.create(title:       data.dig(key, :title),
                        description:  data.dig(key, :description),
                        salary:       data.dig(key, :salary),
                        end_at:       data.dig(key, :end_at),
                        experience:   data.dig(key, :exp),
                        level:        data.dig(key, :level),
                        company_id:   company.id,
                        city_id:      city.id)
        data.dig(key, :industries).each do |i|
          job.industries << Industry.find_or_create_by(name: i)
        end
      end        
    end
  end
end