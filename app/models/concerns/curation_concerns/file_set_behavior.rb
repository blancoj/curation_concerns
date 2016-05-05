module CurationConcerns
  module FileSetBehavior
    extend ActiveSupport::Concern
    # BasicMetadata needs to be included before Characterization since
    # both of them declare properties with the same predicate (dc:creator
    # and dc:language.) Loading BasicMetadata first allows Characterization
    # to detect the duplicate (via the AlreadyThereStrategy) and prevents
    # the warning.
    include CurationConcerns::BasicMetadata
    include Hydra::Works::FileSetBehavior
    include Hydra::Works::VirusCheck
    include CurationConcerns::Characterization
    include Hydra::WithDepositor
    include CurationConcerns::Serializers
    include CurationConcerns::Noid
    include CurationConcerns::FileSet::Derivatives
    include CurationConcerns::Permissions
    include CurationConcerns::FileSet::FullTextIndexing
    include CurationConcerns::FileSet::Indexing
    include CurationConcerns::FileSet::BelongsToWorks
    include CurationConcerns::FileSet::Querying
    include CurationConcerns::HumanReadableType
    include CurationConcerns::RequiredMetadata
    include CurationConcerns::Naming
    include Hydra::AccessControls::Embargoable
    include GlobalID::Identification

    included do
      attr_accessor :file
      self.human_readable_type = 'File'
    end

    def representative_id
      to_param
    end

    def thumbnail_id
      to_param
    end
  end
end
