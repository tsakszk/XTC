class BooksController < ApplicationController
  def show
    @book = Book.find(params[:id])
    @newbook = Book.new
    @book_comment = BookComment.new
  end

  def index
    @book = Book.new
    @user = User.find(current_user.id)
    @books = Book.all.page(params[:page]).per(5).order(created_at: :desc) #:asc古い :desc新しい
    @all_user_ranks = User.find(Favorite.group(:user_id).order('count(user_id) desc').limit(5).pluck(:user_id))
    @all_book_ranks = Book.find(Favorite.group(:book_id).order('count(book_id) desc').limit(5).pluck(:book_id))
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      tags = Vision.get_image_data(@book.image)
      tags.each do |tag|
        @book.tags.create(name: tag)
      end
      redirect_to book_path(@book.id), notice: "successfully created book!"
    else
      @user = User.find(current_user.id)
      @books = Book.all
      render :index
    end
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user == current_user
    else
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to @book, notice: "successfully updated book!"
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path, notice: "successfully delete book!"
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :image)
  end
end
