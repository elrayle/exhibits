# frozen_string_literal: true

require 'rails_helper'

describe UploadSolrDocumentBuilder do
  subject(:builder) { described_class.new resource }

  let(:exhibit) { create(:exhibit) }
  let(:upload_id) { 123 }
  let(:upload) { Spotlight::FeaturedImage.new(id: upload_id) }
  let(:riiif_image) do
    instance_double(Riiif::Image, info: instance_double('Dimensions', width: 5, height: 5))
  end

  let(:resource) { Spotlight::Resources::Upload.create! exhibit: exhibit, upload: upload }

  before do
    allow(Riiif::Image).to receive(:new).with(upload_id).and_return(riiif_image)
    allow(upload).to receive(:file_present?).and_return(true)
  end

  describe '#to_solr' do
    it 'adds a square thumbnail field' do
      expect(builder.to_solr).to include thumbnail_square_url_ssm: "/images/#{upload_id}/square/100,100/0/default.jpg"
    end

    it 'adds a large image field' do
      expect(builder.to_solr).to include large_image_url_ssm: "/images/#{upload_id}/full/!1000,1000/0/default.jpg"
    end

    it 'copies over the uploaded date field to pub_year fields' do
      resource.sidecar.update data: {
        'configured_fields' => { 'spotlight_upload_date_tesim' => 'this is a year: 2014' }
      }

      expect(builder.to_solr).to include pub_year_tisim: 2014, pub_year_w_approx_isi: 2014, pub_year_isi: 2014
    end
  end
end
