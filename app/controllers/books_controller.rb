class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book.id)
      current_user.view_counts.create(book_id: @book.id)
    end
  end

  def index
    if params[:latest]
      @books = Book.all.order(created_at: :desc)
    elsif params[:star_count]
      @books = Book.all.order(evaluation: :desc)
    else
      to = Time.current.at_end_of_day
      from = (to - 6.day).at_beginning_of_day
      @books = Book.all.sort { |a, b|
        b.favorites.where(created_at: from...to).size <=>
        a.favorites.where(created_at: from...to).size
      }
    end
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    tag_list = params[:book][:tag_name].split(",") # カンマ区切りで複数タグ付けが可能
    if @book.save
      @book.save_tags(tag_list)
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render "index"
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    if @book.destroy
      flash[:notice] = "Book was successfully destroyed."
      redirect_to books_path
    end
  end

  private
    def book_params
      params.require(:book).permit(:title, :body, :evaluation)
    end

    def ensure_correct_user
      @book = Book.find(params[:id])
      unless @book.user == current_user
        redirect_to books_path
      end
    end
end
