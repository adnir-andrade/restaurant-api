# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenuItemsController, type: :controller do
  describe 'GET #index' do
    subject { response }

    let!(:menu_item) { create(:menu_item) }

    before { get :index }

    it { is_expected.to have_http_status(:ok) }

    it 'returns JSON with array' do
      json = response.parsed_body
      expect(json).to contain_exactly(serialized_menu_item(menu_item))
    end
  end

  describe 'GET #show' do
    subject { response }

    context 'when menu_item exists' do
      let!(:menu_item) { create(:menu_item) }

      before { get :show, params: { id: menu_item.id } }

      it { is_expected.to have_http_status(:ok) }

      it 'returns serialized menu_item' do
        json = response.parsed_body
        expect(json).to eq(serialized_menu_item(menu_item))
      end
    end

    context 'when menu_item does not exist' do
      before { get :show, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'POST #create' do
    subject { response }

    context 'with valid attributes' do
      let(:attributes) { attributes_for(:menu_item) }

      before { post :create, params: { menu_item: attributes } }

      it { is_expected.to have_http_status(:created) }

      it 'returns the created item' do
        expect(response.parsed_body['name']).to eq(attributes[:name])
      end
    end

    context 'with invalid attributes' do
      context 'when name is not present' do
        before { post :create, params: { menu_item: { name: nil } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not save the item' do
          expect(MenuItem.count).to eq(0)
        end
      end

      context 'when price is not present' do
        before { post :create, params: { menu_item: { price: nil } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not save the item' do
          expect(MenuItem.count).to eq(0)
        end
      end

      context 'when price is negative' do
        before { post :create, params: { menu_item: { price: -1 } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not save the item' do
          expect(MenuItem.count).to eq(0)
        end
      end
    end
  end

  describe 'PATCH #update' do
    subject { response }

    let!(:item) { create(:menu_item, :pancake) }

    context 'with valid attributes' do
      before { patch :update, params: { id: item.id, menu_item: { name: 'New Pancake' } } }

      it { is_expected.to have_http_status(:ok) }

      it 'updates the item' do
        expect(item.reload.name).to eq('New Pancake')
      end
    end

    context 'with invalid attributes' do
      context 'when name is blank' do
        before { patch :update, params: { id: item.id, menu_item: { name: '' } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the name' do
          expect(item.reload.name).to eq('Pancake')
        end
      end

      context 'when price is blank' do
        before { patch :update, params: { id: item.id, menu_item: { price: '' } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the price' do
          expect(item.reload.price).to eq(7.77)
        end
      end

      context 'when price is negative' do
        before { patch :update, params: { id: item.id, menu_item: { price: -0.01 } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the price' do
          expect(item.reload.price).to eq(7.77)
        end
      end
    end

    context 'when menu_item does not exist' do
      before { patch :update, params: { id: 'imaginary-id', menu_item: { name: 'Any' } } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'DELETE #destroy' do
    subject { response }

    context 'when item exists' do
      let!(:item) { create(:menu_item) }

      before { delete :destroy, params: { id: item.id } }

      it { is_expected.to have_http_status(:no_content) }

      it 'removes the item' do
        expect(MenuItem).not_to exist(item.id)
      end
    end

    context 'when menu_item does not exist' do
      before { delete :destroy, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'POST #assign_to_menu' do
    subject { response }

    let!(:menu) { create(:menu) }
    let!(:menu_item) { create(:menu_item, menu: nil) }

    context 'when both exist and are valid' do
      before do
        post :assign_to_menu, params: { id: menu_item.id, menu_id: menu.id }
      end

      it { is_expected.to have_http_status(:ok) }

      it 'assigns the item to the menu' do
        expect(menu_item.reload.menu_id).to eq(menu.id)
      end

      context 'when the item is already assigned to another menu' do
        let!(:another_menu) { create(:menu) }

        before do
          menu_item.menu_id = another_menu.id
          post :assign_to_menu, params: { id: menu_item.id, menu_id: menu.id }
        end

        it { is_expected.to have_http_status(:ok) }

        it 'assigns the item to the menu' do
          expect(menu_item.reload.menu_id).to eq(menu.id)
        end
      end
    end

    context 'when menu_item does not exist' do
      before { post :assign_to_menu, params: { id: 'imaginary-id', menu_id: menu.id } }

      it { is_expected.to have_http_status(:not_found) }
    end

    context 'when menu does not exist' do
      before { post :assign_to_menu, params: { id: menu_item.id, menu_id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
