# frozen_string_literal: true

class MenuItemsController < ApplicationController
  before_action :set_menu_item, only: %i[show update destroy assign_to_menu]
  before_action :set_menu, only: %i[assign_to_menu]

  def index
    menu_items = MenuItem.all
    render json: menu_items
  end

  def show
    render json: @menu_item
  end

  def create
    menu_item = MenuItem.new(menu_item_params)

    if menu_item.save
      render json: menu_item, status: :created
    else
      render json: { errors: menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
  end

  def assign_to_menu
    Rails.logger.info(
      "--- Assigning MenuItem (##{@menu_item.id} - #{@menu_item.name}) to Menu (##{@menu.id} - #{@menu.name}) ---"
    )

    @menu_item.menu = @menu

    if @menu_item.save
      render json: @menu_item, status: :ok
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def set_menu
    @menu = Menu.find(params[:menu_id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price)
  end
end
