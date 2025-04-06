# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestaurantsController, type: :controller do
  describe 'GET #index' do
    subject { response }

    let!(:restaurant) { create(:restaurant) }

    before { get :index }

    it { is_expected.to have_http_status(:ok) }

    it 'returns serialized content' do
      json = response.parsed_body
      expect(json).to eq([serialized_restaurant(restaurant)])
    end
  end

  describe 'GET #show' do
    subject { response }

    context 'when restaurant exists' do
      let!(:restaurant) { create(:restaurant) }

      before { get :show, params: { id: restaurant.id } }

      it { is_expected.to have_http_status(:ok) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_restaurant(restaurant))
      end
    end

    context 'when restaurant does not exist' do
      before { get :show, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'POST #create' do
    subject { response }

    context 'when attributes are valid' do
      let(:restaurant_attributes) { attributes_for(:restaurant) }

      before { post :create, params: { restaurant: restaurant_attributes } }

      it { is_expected.to have_http_status(:created) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_restaurant(Restaurant.last))
      end
    end

    context 'when attributes are invalid' do
      context 'when name is missing' do
        let(:restaurant_attributes) { attributes_for(:restaurant, name: nil) }

        before { post :create, params: { restaurant: restaurant_attributes } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not save the restaurant' do
          expect(Restaurant.count).to eq(0)
        end
      end
    end
  end

  describe 'PATCH #update' do
    subject { response }

    context 'when attributes are valid' do
      let!(:restaurant) { create(:restaurant) }

      before { patch :update, params: { id: restaurant.id, restaurant: { name: 'La Bodega' } } }

      it { is_expected.to have_http_status(:ok) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_restaurant(Restaurant.last))
      end
    end

    context 'when attributes are invalid' do
      let!(:restaurant) { create(:restaurant) }

      context 'when name is missing' do
        before { patch :update, params: { id: restaurant.id, restaurant: { name: '' } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the name' do
          expect(restaurant.reload.name).not_to eq('')
        end
      end
    end

    context 'when restaurant does not exist' do
      before { patch :update, params: { id: 'imaginary-id', restaurant: { name: 'Anything' } } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'DELETE #destroy' do
    subject { response }

    let!(:restaurant) { create(:restaurant) }
    let!(:menu) { create(:menu, restaurant: restaurant) }

    context 'when restaurant exists' do
      before { delete :destroy, params: { id: restaurant.id } }

      it { is_expected.to have_http_status(:no_content) }

      it 'removes the restaurant from the database' do
        expect(Restaurant).not_to exist(restaurant.id)
      end

      it 'removes the associated menus' do
        expect(Menu).not_to exist(menu.id)
      end
    end

    context 'when restaurant does not exist' do
      before { delete :destroy, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
