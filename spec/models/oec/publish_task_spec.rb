describe Oec::PublishTask do

  describe 'Publish' do
    let(:term_code) { '2015-B' }
    let(:fake_remote_drive) { double() }
    let(:now) { DateTime.now }
    let(:task) { Oec::PublishTask.new term_code: term_code }
    let(:tmp_publish_directory) { now.strftime "publish_#{Oec::Task.date_format}_%H%M%S" }

    context 'sftp command' do
      before do
        allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive
        allow(fake_remote_drive).to receive(:find_nested).with(term_code, 'exports') # .and_return (exports_folder = double())
        allow(fake_remote_drive).to receive(:find_folders).with('mock_id').and_return (exports_folder_listing = double())
        allow(exports_folder_listing).to receive(:sort_by) { exports_folder_listing }
        most_recent_folder = double()
        allow(exports_folder_listing).to receive(:last) { most_recent_folder }
        allow(most_recent_folder).to receive(:title) { now.strftime  "#{Oec::Task.date_format} #{Oec::Task.timestamp_format}" }

        parent_dir = mock_google_drive_item
        allow(fake_remote_drive).to receive(:find_nested).and_return parent_dir
        allow(fake_remote_drive).to receive(:check_conflicts_and_create_folder).and_return mock_google_drive_item
        allow(fake_remote_drive).to receive(:check_conflicts_and_upload)
        task.files_to_publish.each do |file|
          name = file.chomp('.csv')
          item = mock_google_drive_item(name)
          allow(fake_remote_drive).to receive(:find_first_matching_item).with(name, parent_dir).and_return item
          allow(fake_remote_drive).to receive(:export_csv).with(item).and_return "content_of_#{file}"
        end
      end

      after do
        Dir.glob(Rails.root.join 'tmp', 'oec', "*#{Oec::PublishTask.name.demodulize.underscore}.log").each do |file|
          expect(File.open(file, 'rb').read).to include["#{tmp_publish_directory}/courses.csv", 'sftp://']
          FileUtils.rm_rf file
        end
      end

      it 'should run system command with datetime_to_publish in path' do
        expect(task).to receive(:system).and_return true
        expect(task.run).to be true
      end

      it 'should raise error when \'system\' returns false' do
        expect(task).to receive(:system).and_return false
        Rails.logger.warn "\n\nThe logs will get a verbose error message and stack trace during this test.\n"
        expect(task.run).to be_nil
      end
    end

  end
end
