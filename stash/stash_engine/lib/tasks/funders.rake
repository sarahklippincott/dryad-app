require 'csv'
require 'byebug'
require_relative 'funders/utils'

namespace :funders do
  desc 'Set crossref funders for exact matches'
  task set_crossref_funders: :environment do
    # name as key, value is fundref doi
    lookup = Funders::Utils.new.lookup

    StashDatacite::Contributor.where(contributor_type: 'funder').where('name_identifier_id IS NULL or name_identifier_id = ""')
      .each_with_index do |contrib, idx|
      simple_name = contrib.contributor_name.gsub(/\*$/, '').strip.downcase # remove a star at the end if there is one and downcase

      contrib.update!(contributor_name: lookup[simple_name][:name], name_identifier_id: lookup[simple_name][:uri]) if lookup[simple_name].present?

      puts "Checked #{idx} funders for missing ids" if idx % 100 == 0 && idx != 0
    end
  end

  desc 'export similarity for unmatched to CSV'
  task similarity_csv: :environment do
    util = Funders::Utils.new

    sql = <<-SQL
      SELECT REPLACE(c.contributor_name, '*', '') as contrib, COUNT(*) as count FROM dcs_contributors c
      JOIN stash_engine_resources res
      ON c.`resource_id` = res.id
      WHERE res.meta_view = 1 AND
      c.contributor_type = "funder" AND
      (c.name_identifier_id IS NULL OR c.name_identifier_id = '')
      GROUP BY contrib
      ORDER BY COUNT(*) DESC
    SQL

    records_array = ActiveRecord::Base.connection.exec_query(sql)

    CSV.open('funder_suggestions.csv', 'wb') do |csv|

      csv << %w[database_funder number sugg_funder sugg_id]

      count = 0
      records_array.rows.each do |i|
        count += 1
        match = util.best_match(name: i[0]) || {}

        csv << [i[0].strip, i[1], match[:name], match[:uri]]
        puts "checked #{count}" if count % 100 == 0
      end
      puts 'Output file funder_suggestions.csv'
    end
  end

  desc 'update IDs for re-importing spreadsheet for items manually matched/entered'
  task import_manual_lookup_csv: :environment do
    CSV.foreach('/Users/sfisher/Downloads/Funders-10-11-21.csv', headers: true) do |row|
      # find 'database_funder' and 'sugg_id', if 'sugg_id' is filled in then update those items in the database that match
      # the string to have that funder id
      next if row['sugg_id'].blank?

      StashDatacite::Contributor
        .where("contributor_name LIKE ? AND contributor_type = 'funder' AND (name_identifier_id IS NULL OR name_identifier_id = '')",
               "#{row['database_funder'].strip}%").each_with_index do |contrib, idx|

        better_name = contrib.contributor_name.gsub(/[* ]+$/, '') # removes stars and spaces from the end
        if better_name.downcase == row['database_funder'].strip.downcase
          puts "#{idx} -- Updating: #{row['database_funder']} to have id #{row['sugg_id']}"
          contrib.update(contributor_name: better_name, name_identifier_id: row['sugg_id'].strip)
        end
      end

      puts ''
    end
  end

  # had to do this to fix Tedfile with inconsistent line endings and even multiple line endings (making blank lines)
  # File.open('funderOutputCrossrefFixed__20211006.csv', 'w') do |outfile|
  #   File.foreach('funderOutputCrossref__20211006.csv') do |line|
  #     better_line = line.strip
  #     next if better_line.empty?
  #     outfile.puts better_line
  #   end
  # end
  # This also created a crazy unprintable character on the first line as part of the "doi" field which was hard to
  # troubleshoot.  Had to edit it out in binary mode in vi.

  desc 'imports Tedsheet which is something someone gave us with IDs for some funders'
  task import_tedsheet: :environment do
    CSV.foreach('/Users/sfisher/Downloads/funderOutputCrossrefFixed__20211006.csv', headers: true) do |row|
      # relevant fields are 'doi', 'funderName', 'funderIdentifier', there seem to be a lot of blank rows
      next if row['funderIdentifier'].blank?

      stash_identifier = StashEngine::Identifier.where(identifier: row['doi']).first
      next if stash_identifier.nil?

      res = stash_identifier.latest_resource_with_public_metadata
      next if res.nil?

      existing_count = res.contributors.where(contributor_type: 'funder', contributor_name: row['funderName']).count
      next if existing_count.positive? # it already got added, so skip

      full_id = "http://dx.doi.org/#{row['funderIdentifier']}" # because dx.doi.org is how fundref presents them

      StashDatacite::Contributor.create!(
        contributor_name: row['funderName'],b
        contributor_type: 'funder',
        name_identifier_id: full_id,
        resource_id: res.id,
        award_number: row['awardNumber']
      )

      puts "Added #{row['funderName']} as funder for #{row['doi']}"
    end
  end
end
