# This module points the FileSet to the location of the technical metdata.
# By default, the file holding the metadata is :original_file and the terms
# are listed under ::characterization_terms.
# Implementations may define their own terms or use a different source file, but
# any terms must be set on the ::characterization_proxy by the Hydra::Works::CharacterizationService
#
# class MyFileSet
#   include CurationConcerns::FileSetBehavior
#
#   self.characterization_proxy = :master_file
#   self.characterization_terms = [:term1, :term2, :term3]
#
# end
module CurationConcerns
  module Characterization
    extend ActiveSupport::Concern

    included do
      def self.characterization_terms
        [:mime_type, :format_label, :file_size, :height, :width, :filename]
      end

      def self.characterization_proxy
        :original_file
      end

      delegate(*characterization_terms, to: :characterization_proxy)

      def characterization_proxy
        @characterization_proxy ||= (send(self.class.characterization_proxy) || NullCharacterizationProxy.new)
      end
    end

    class NullCharacterizationProxy
      def method_missing(*_args)
        []
      end
    end
  end
end
