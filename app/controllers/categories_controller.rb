class CategoriesController < ApplicationController

  def index
    @categories = Category.all
  end

  def show
    @category = Category.find_by(id: params[:id])
    if @category.nil?
      head :not_found
      return
    end
  end


  def edit
    @category = Category.find_by(id: params[:id])
    if @category.nil?
      head :not_found
      return
    end
  end

  def update
    @category = Category.find_by(id: params[:id])

    if @category.nil?
      head :not_found
      return
    elsif @category.update(category_params)
      redirect_to categories_path(@category)
      return
    else
      render :bad_request
      return
    end
  end



  private
  def category_params
    return params.require(:category).permit(:category_id, :name)
  end
end
