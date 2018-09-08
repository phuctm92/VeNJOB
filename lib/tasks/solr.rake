require 'rsolr'

namespace :solr do
  include ActionView::Helpers::SanitizeHelper
  
  desc "import data from mySQL to Solr"
  task import: :environment do
    solr = RSolr.connect url: "http://localhost:8983/solr/venjob"

    Job.find_each do |job|
      solr.add(id: job.id,
                job_title: job.title,
                job_description: strip_tags(job.description),
                salary: job.salary,
                city_id: job.city.id,
                city_name: job.city.name,
                company_id: job.company.id,
                company_name: job.company.name,
                industry_id: job.industry_ids,
                industry_name: job.industries.map(&:name),
                min_salary: min_salary(job.salary)
                )
      puts "Done"
    end
    solr.commit
  end

  desc "Delete data in Solr"
  task delete: :environment do
    solr = RSolr.connect url: "http://localhost:8983/solr/venjob"
    solr.delete_by_query '*:*'
    solr.commit
    puts "Done"
  end

  task :search, [:argument1, :argument2] do |t, args|
    solr = RSolr.connect url: "http://localhost:8983/solr/venjob"
    response = solr.get('select', params: 
      {q: "#{args[:argument1]}:'#{args[:argument2]}'", fl: "id, job_title", wt: :json})
    response['response']['docs'].each do |e|
      puts e["id"]
      puts e["job_title"]
    end
  end

  def min_salary(salary)
    return if salary.include?("Cạnh tranh")
    min_salary = salary.split("-").map {|s| s.gsub(/[^\d]/, '')}[0].to_i
    salary.include?("USD") ? min_salary*23000 : min_salary
  end

  #min_salary:[10000000 TO *]
end