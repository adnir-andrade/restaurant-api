# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenusController, type: :controller do
  describe 'GET #index' do
    subject { response }

    let!(:menu) { create(:menu) }

    before { get :index }

    it { is_expected.to have_http_status(:ok) }

    it 'returns JSON with array' do
      json = response.parsed_body
      expect(json).to contain_exactly(serialized_menu(menu))
    end

    it 'returns serialized content' do
      json = response.parsed_body

      expect(json).to eq([serialized_menu(menu)])
    end
  end

  describe 'GET #show' do
    subject { response }

    context 'when menu exists' do
      let!(:menu) { create(:menu) }

      before { get :show, params: { id: menu.id } }

      it { is_expected.to have_http_status(:ok) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_menu(menu))
      end
    end

    context 'when menu does not exist' do
      before { get :show, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'POST #create' do
    subject { response }

    context 'when attributes are valid' do
      let(:menu_attributes) { attributes_for(:menu) }

      before { post :create, params: { menu: menu_attributes } }

      it { is_expected.to have_http_status(:created) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_menu(Menu.last))
      end
    end

    context 'when attributes are invalid' do
      let(:menu_attributes) { attributes_for(:menu, name: nil) }

      before { post :create, params: { menu: menu_attributes } }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it 'does not save the menu' do
        expect(Menu.count).to eq(0)
      end
    end
  end

  describe 'PATCH #update' do
    subject { response }

    context 'when attributes are valid' do
      let!(:pizza_menu) { create(:menu, :pizza) }

      context 'when changing name' do
        before { patch :update, params: { id: pizza_menu.id, menu: { name: 'Italian food' } } }

        it { is_expected.to have_http_status(:ok) }

        it 'returns serialized content' do
          json = response.parsed_body
          expect(json).to eq(serialized_menu(Menu.last))
        end
      end

      context 'when changing description' do
        before { patch :update, params: { id: pizza_menu.id, menu: { description: '' } } }

        it { is_expected.to have_http_status(:ok) }

        it 'returns serialized content' do
          json = response.parsed_body
          expect(json).to eq(serialized_menu(Menu.last))
        end
      end
    end

    context 'when attributes are invalid' do
      let!(:pizza_menu) { create(:menu, :pizza) }

      before { patch :update, params: { id: pizza_menu.id, menu: { name: '' } } }

      it { is_expected.to have_http_status(:unprocessable_entity) }

      it 'does not change name' do
        expect(Menu.last.name).to eq('Pizzas')
      end
    end

    context 'when menu does not exist' do
      before { patch :update, params: { id: 'imaginary-id', menu: { name: 'Anything' } } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'DELETE #destroy' do
    subject { response }

    let!(:menu) { create(:menu) }

    context 'when the menu has associated menu_items' do
      let(:reloaded_menu_item) { MenuItem.find(menu_item.id) }

      let!(:menu_item) { create(:menu_item) }

      before { delete :destroy, params: { id: menu.id } }

      it { is_expected.to have_http_status(:no_content) }

      it 'does not delete the associated menu_items' do
        expect { reloaded_menu_item }.not_to raise_error
      end

      it 'removes the menu from menu_item.menus list' do
        expect(reloaded_menu_item.menus).not_to include(menu)
      end
    end

    context 'when menu does not have associated menu_items' do
      before { delete :destroy, params: { id: menu.id } }

      it { is_expected.to have_http_status(:no_content) }

      it 'removes the menu from the database' do
        expect(Menu).not_to exist(menu.id)
      end
    end

    context 'when menu does not exist' do
      before { delete :destroy, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
