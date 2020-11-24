class ProductsController < ApplicationController

  before_action :find_product, only: [:show, :edit, :update, :destroy, :update_status]
  before_action :require_login, only: [:new, :edit, :create, :update]

  before_action :set_page, only: [:index]
  PRODUCTS_PER_PAGE = 6

  def index
     if params[:category_id]
      category = Category.find_by(id: params[:category_id])
      @products = category.products.limit(PRODUCTS_PER_PAGE).offset(@page * PRODUCTS_PER_PAGE)
    elsif params[:merchant_id]
      @merchant = Merchant.find_by(id: params[:merchant_id])
    @products = @merchant.products.limit(PRODUCTS_PER_PAGE).offset(@page * PRODUCTS_PER_PAGE)
    else
      @products = Product.all.limit(PRODUCTS_PER_PAGE).offset(@page * PRODUCTS_PER_PAGE)
    end
  end

  def show
    # @product = Product.find_by(id: params[:id])
    if @product.nil?
      head :not_found
      return
    end
  end

  def new
    @product = Product.new
  end

  def create
    # merchant = if params[:merchant_id]
    #              Merchant.find_by(id: params[:merchant_id])
    #            elsif params[:product][:merchant_id]
    #              Merchant.find_by(id: params[:product][:merchant_id])
    #            end
    merchant = @current_merchant

    @product = merchant.products.new(product_params)
    # @product.default
    if @product.save
      if params[:merchant_id]
      flash[:success] = "Successfuly created #{@product.category} #{@product.id}"
      redirect_to merchant_product_path(id: @product.id)
      else
        redirect_to product_path(@product.id)
      end
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  def edit

    if @product.nil?
      head :not_found
      return
    end
  end

  def update

    if @product.nil?
      head :not_found
      return
    elsif @product.update(product_params)
      flash[:success] = "Succesfully updated #{@product.name}"
      redirect_to product_path(@product)
    else # save failed
      @product.errors.each do |column, message|
        flash.now[:error] = "A problem occurred: Could not #{action_name} #{@product.name} #{column}: #{message}"
      end

      render :edit, status: :bad_request
      return
    end
  end

  def update_status
    if @product.status == "active"
      @product.update_attribute(:status, "retired")
      flash[:success] = "Succesfully set the product to #{@product.status}"
      redirect_to merchant_path(@current_merchant)

    else
      @product.update_attribute(:status, "active")
      flash[:success] = "Succesfully set the product to #{@product.status}"
      redirect_to merchant_path(@current_merchant)
    end


  end

  def destroy
    # product_id = params[:id]
    # @product = Product.find_by(id: product_id)
    if @product
      @product.destroy
      if params[:merchant_id]
        redirect_to merchant_path(params[:merchant_id])
      else
        redirect_to products_path
      end
    else
      head :not_found
      return
    end
  end

  private

  def product_params
    return params.require(:product).permit(:name, :price, :description, :photo_url, :inventory_stock, :merchant_id, category_ids: [])
  end

  def find_product
    @product = Product.find_by(id: params[:id])
  end

  def set_page
    @page = params[:page].to_i || 0
  end
end
