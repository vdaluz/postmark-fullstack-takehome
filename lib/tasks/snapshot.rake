desc 'Take a snapshot of in-app communications using the Postmark Messages API'
namespace :snapshot do
  task take: :environment do
    snapshot = Snapshot.take
    snapshot.save

    puts "Snapshot complete."
  end
end
