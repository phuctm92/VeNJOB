require 'open-uri'

namespace :crawler do

  task :get_jobs  do
    @cities     = get_value_from_dropdown("location2")
    @industries = get_value_from_dropdown("industry2")

    page = 15
    current_page = 1
    @data = []
    while current_page <= page
      url = Nokogiri::HTML(open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-trang-#{current_page}-vi.html"))

      url.css('h3.job a').each do |link|
        begin
          job_doc = Nokogiri::HTML(open(URI.parse(URI.escape(link['href']))))
        rescue OpenURI::HTTPError => e
          next
        end

        title = job_doc.css('.top-job-info h1').text
        next if title.blank?

        company_name = job_doc.css('.top-job-info .tit_company').text
        company_addr = job_doc.css('p.TitleDetailNew label label').text
        
        cities_name  = get_details_by_span(job_doc, "Nơi làm việc: ").split(", ")
        industries   = get_details_by_span(job_doc, "Ngành nghề: ").split(", ")
        level        = get_details_by_span(job_doc, "Cấp bậc: ")
        salary       = get_details_by_span(job_doc, "Lương: ")
        exp          = get_details_by_span(job_doc, "Kinh nghiệm: ")
        end_at       = get_details_by_span(job_doc, "Hết hạn nộp: ")

        description = ''
        job_doc.css('.MarBot20').children.map do |element| 
          element.remove_attribute('class')
          description << element.to_html
        end
        description = description.squish

        @data << { title: title, company_name: company_name, company_addr: company_addr, cities_name: cities_name, industries: industries, level: level,
          salary: salary, exp: exp, end_at: end_at, description: description}

        puts "#{link['href']}"
        puts "------------------------------------------------------------------------"
      end
      current_page += 1
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

  task import: :environment do
    Rake::Task["crawler:get_jobs"].invoke
    
    @cities.each {|city| City.find_or_create_by(name: city)}
    City.where('id > 70').update_all(domestic: false)
    @industries.each {|industry| Industry.find_or_create_by(name: industry) }
    
    @data.each do |d|
      company = Company.find_or_create_by(name: d[:company_name]) do |c|
        c.address = d[:company_addr]
      end
      
      d[:cities_name].each do |c|
        city = City.find_by_name(c)
        job = Job.create(title:       d[:title],
                        description:  d[:description],
                        salary:       d[:salary],
                        end_at:       d[:end_at],
                        experience:   d[:exp],
                        level:        d[:level],
                        company_id:   company.id,
                        city_id:      city.id)
        d[:industries].each do |industry|
          job.industries << Industry.find_or_create_by(name: industry)
        end
      end        
    end
  end
end