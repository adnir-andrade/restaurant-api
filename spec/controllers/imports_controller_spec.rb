# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportsController, type: :controller do
  describe 'POST #create' do
    subject { response }

    let(:headers) { { 'CONTENT_TYPE' => 'multipart/form-data' } }

    context 'with perfect data' do
      let(:file) { fixture_file_upload(file_fixture('perfect_data.json')) }

      before { post :create, params: { file: file } }

      it { is_expected.to have_http_status(:ok) }

      it 'returns success message' do
        expect(json_response['status']).to eq('Success')
      end
    end

    context 'with partially good data' do
      let(:file) { fixture_file_upload(file_fixture('partially_good.json')) }

      before { post :create, params: { file: file } }

      it { is_expected.to have_http_status(:multi_status) }

      it 'returns partial success message' do
        expect(json_response['status']).to eq('Partially successful')
      end
    end

    context 'with missing root key (invalid data)' do
      let(:file) { fixture_file_upload(file_fixture('missing_root_key.json')) }

      before { post :create, params: { file: file } }

      it { is_expected.to have_http_status(:bad_request) }

      it 'returns failed message' do
        expect(json_response['status']).to eq('Failed')
      end
    end

    context 'with invalid file param (no file uploaded)' do
      before { post :create }

      it { is_expected.to have_http_status(:bad_request) }

      it 'returns error message' do
        expect(json_response['error']).to include('Missing required parameter')
      end
    end

    def json_response
      response.parsed_body
    end
  end
end
