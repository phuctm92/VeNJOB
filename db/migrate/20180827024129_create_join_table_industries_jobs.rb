class CreateJoinTableIndustriesJobs < ActiveRecord::Migration[5.2]
  def change
    create_join_table :industries, :jobs, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.index :industry_id
      t.index :job_id
    end
  end
end
