require 'open-uri'

namespace :crawler do

  task :get_jobs  do
    @cities     = get_value_from_dropdown("location2")
    @industries = get_value_from_dropdown("industry2")

    page = 15
    current_page = 1
    id = 0
    @data = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }
    while current_page <= page
      url = Nokogiri::HTML(open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-trang-#{current_page}-vi.html"))

      url.css('h3.job a').map do |link|
        begin
          job_doc = Nokogiri::HTML(open(URI.parse(URI.escape(link['href']))))
        rescue OpenURI::HTTPError => e
          next
        end

        @data["job_#{id}".to_s][:title] = job_doc.css('.top-job-info h1').text
        next if @data["job_#{id}".to_s][:title].blank?

        @data["job_#{id}".to_s][:company_name] = job_doc.css('.top-job-info').css('.tit_company').text
        @data["job_#{id}".to_s][:company_addr] = job_doc.css('p.TitleDetailNew').css('label label').text
        
        @data["job_#{id}".to_s][:cities_name]  = get_details_by_span(job_doc, "Nơi làm việc: ").split(", ")
        @data["job_#{id}".to_s][:industries]   = get_details_by_span(job_doc, "Ngành nghề: ").split(", ")
        @data["job_#{id}".to_s][:level]        = get_details_by_span(job_doc, "Cấp bậc: ")
        @data["job_#{id}".to_s][:salary]       = get_details_by_span(job_doc, "Lương: ")
        @data["job_#{id}".to_s][:exp]          = get_details_by_span(job_doc, "Kinh nghiệm: ")
        @data["job_#{id}".to_s][:end_at]       = get_details_by_span(job_doc, "Hết hạn nộp: ")

        description = ''
        job_doc.css('.MarBot20').children.map do |element| 
          element.remove_attribute('class')
          description << element.to_html
        end
        @data["job_#{id}".to_s][:description] = description.squish
        id += 1

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

  task import_data: :environment do
    Rake::Task["crawler:get_jobs"].invoke
    
    @cities.each {|c| City.find_or_create_by(name: c) }
    City.where('id > 70').update_all(domestic: false)
    @industries.each {|i| Industry.find_or_create_by(name: i) }
    @data.each do |k,v|
      company = Company.find_or_create_by(name: @data.dig(k, :company_name)) do |c|
        c.address = @data.dig(k, :company_addr)
      end
      
      @data.dig(k, :cities_name).each do |c|
        city = City.find_by_name(c)
        job = Job.create(title:       @data.dig(k, :title),
                        description:  @data.dig(k, :description),
                        salary:       @data.dig(k, :salary),
                        end_at:       @data.dig(k, :end_at),
                        experience:   @data.dig(k, :exp),
                        level:        @data.dig(k, :level),
                        company_id:   company.id,
                        city_id:      city.id)
        @data.dig(k, :industries).each do |i|
          job.industries << Industry.find_or_create_by(name: i)
        end
      end        
    end
  end
end