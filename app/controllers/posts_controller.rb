class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    @posts = @posts.global_search(params[:query]) if params[:query].present?
    @pagy, @posts = pagy @posts.reorder(sort_column => sort_direction), items: params.fetch(:count, 4)
  end

  def sort_column
    %w{ title }.include?(params[:sort]) ? params[:sort] : "title"
  end

  def sort_direction
    %w{ asc desc }.include?(params[:direction]) ? params[:direction] : "asc"
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    respond_to do |format|
      format.turbo_stream do 
        render turbo_stream: turbo_stream.update(@post,
                                                 partial: "posts/form",
                                                 locals: {post: @post})
      end
    end
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    respond_to do |format|
      if @post.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_post',
                                partial: "posts/form",
                                locals: {post: Post.new}),
            turbo_stream.prepend('posts',
                                partial: "posts/post",
                                locals: {post: @post}),
            turbo_stream.update('notice', "Post #{@post.title} created")
            ]
        end
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('new_post',
                                partial: "posts/form",
                                locals: {post: @post})
            ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.turbo_stream do 
          render turbo_stream: [
            turbo_stream.update(@post,
                                partial: "posts/post",
                                locals: {post: @post}),
            turbo_stream.update('notice', "post #{@post.title} updated")
          ]
        end
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.turbo_stream do 
          render turbo_stream: turbo_stream.update(@post,
                                                   partial: "posts/form",
                                                   locals: {post: @post})
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@post),
          turbo_stream.update('notice', "post #{@post.title} deleted")
          ]
      end
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title,:image)
    end
end
