require 'spec_helper'

describe ImportUrlJob do
  let(:user) { create(:user) }

  let(:file_path) { fixture_path + '/world.png' }
  let(:file_hash) { '/673467823498723948237462429793840923582' }

  let(:file_set) do
    FileSet.new(import_url: "http://example.org#{file_hash}",
                label: file_path) do |f|
      f.apply_depositor_metadata(user.user_key)
    end
  end

  let(:mock_response) do
    double('response').tap do |http_res|
      allow(http_res).to receive(:start).and_yield
      allow(http_res).to receive(:content_type).and_return('image/png')
      allow(http_res).to receive(:read_body).and_yield(File.open(File.expand_path(file_path, __FILE__)).read)
    end
  end
  let(:log) { create(:operation) }

  context 'after running the job' do
    let(:actor) { double }

    before do
      file_set.id = 'abc123'
      allow(file_set).to receive(:reload)
      allow(CurationConcerns::FileSetActor).to receive(:new).with(file_set, user).and_return(actor)
    end

    it 'creates the content' do
      expect_any_instance_of(Net::HTTP).to receive(:request_get).with(file_hash).and_yield(mock_response)
      expect(actor).to receive(:create_content).and_return(true)
      described_class.perform_now(file_set, log)
      expect(log.status).to eq 'success'
    end
  end

  context "when a batch update job is running too" do
    let(:title) { { file_set.id => ['File One'] } }
    let(:metadata) { {} }
    let(:visibility) { nil }
    let(:file_set_id) { file_set.id }

    before do
      file_set.save!
      allow(ActiveFedora::Base).to receive(:find).and_call_original
      allow(ActiveFedora::Base).to receive(:find).with(file_set_id).and_return(file_set)
      allow_any_instance_of(CurationConcerns::FileSetActor).to receive(:create_content)
      allow_any_instance_of(Ability).to receive(:can?).and_return(true)
      expect_any_instance_of(Net::HTTP).to receive(:request_get).with(file_hash).and_yield(mock_response)
    end

    it "does not kill all the metadata set by other processes" do
      # run the batch job to set the title
      file_set.update(title: ['File One'])

      # run the import job
      described_class.perform_now(file_set, log)

      # import job should not override the title set another process
      file = FileSet.find(file_set_id)
      expect(file.title).to eq(['File One'])
    end
  end
end
