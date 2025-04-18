# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MenusController, type: :controller do
  describe 'GET #index' do
    subject { response }

    let!(:menu) { create(:menu) }

    before { get :index }

    it { is_expected.to have_http_status(:ok) }

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

  describe 'GET #items' do
    subject { response }

    context 'when menu exists' do
      let!(:menu) { create(:menu) }

      before do
        menu_item1 = create(:menu_item)
        menu_item2 = create(:menu_item)
        menu.menu_items << menu_item1
        menu.menu_items << menu_item2
        get :items, params: { id: menu.id }
      end

      it { is_expected.to have_http_status(:ok) }

      it 'returns an array of serialized menu items' do
        json = response.parsed_body
        serialized_items = menu.menu_items.map { |item| serialized_menu_item(item) }
        expect(json).to eq(serialized_items)
      end
    end

    context 'when menu does not exist' do
      before { get :items, params: { id: 'imaginary-id' } }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'POST #create' do
    subject { response }

    let(:restaurant) { create(:restaurant) }

    context 'when attributes are valid' do
      let(:menu_attributes) { attributes_for(:menu).merge(restaurant_id: restaurant.id) }

      before { post :create, params: { menu: menu_attributes } }

      it { is_expected.to have_http_status(:created) }

      it 'returns serialized content' do
        json = response.parsed_body
        expect(json).to eq(serialized_menu(Menu.last))
      end
    end

    context 'when attributes are invalid' do
      context 'when restaurant does not exist' do
        let(:invalid_restaurant_id) { 'imaginary-id' }

        let(:menu_attributes) { attributes_for(:menu).merge(restaurant_id: invalid_restaurant_id) }

        before { post :create, params: { menu: menu_attributes } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not create a menu' do
          expect(Menu.count).to eq(0)
        end
      end

      context 'when name is duplicated within the same restaurant' do
        let(:menu_attributes) { attributes_for(:menu, name: 'Menu A').merge(restaurant_id: restaurant.id) }

        before do
          create(:menu, name: 'Menu A', restaurant: restaurant)
          post :create, params: { menu: menu_attributes }
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not create a menu' do
          expect(Menu.count).to eq(1)
        end
      end

      context 'when name is missing' do
        let(:menu_attributes) { attributes_for(:menu, name: nil).merge(restaurant_id: restaurant.id) }

        before { post :create, params: { menu: menu_attributes } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not save the menu' do
          expect(Menu.count).to eq(0)
        end
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

      context 'when updating restaurant_id' do
        let!(:new_restaurant) { create(:restaurant) }

        before do
          patch :update, params: { id: pizza_menu.id, menu: { restaurant_id: new_restaurant.id } }
        end

        it { is_expected.to have_http_status(:ok) }

        it 'updates the restaurant_id' do
          expect(pizza_menu.reload.restaurant_id).to eq(new_restaurant.id)
        end
      end
    end

    context 'when attributes are invalid' do
      let!(:pizza_menu) { create(:menu, :pizza) }

      context 'when name is missing' do
        before { patch :update, params: { id: pizza_menu.id, menu: { name: '' } } }

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change name' do
          expect(Menu.last.name).to eq('Pizzas')
        end
      end

      context 'when name is duplicated within the same restaurant' do
        before do
          create(:menu, name: 'Italian food', restaurant: pizza_menu.restaurant)
          patch :update, params: { id: pizza_menu.id, menu: { name: 'Italian food' } }
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the name' do
          expect(pizza_menu.reload.name).to eq('Pizzas')
        end
      end

      context 'when updating restaurant_id and name becomes duplicated' do
        let!(:new_restaurant) { create(:restaurant) }

        before do
          create(:menu, name: 'Pizzas', restaurant: new_restaurant)
          patch :update, params: { id: pizza_menu.id, menu: { restaurant_id: new_restaurant.id } }
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }

        it 'does not change the restaurant_id' do
          expect(pizza_menu.reload.restaurant_id).not_to eq(new_restaurant.id)
        end
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
