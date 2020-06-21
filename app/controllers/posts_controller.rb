class PostsController < ApplicationController
  before_action :user_correct, only:[:destroy, :edit, :update]
  before_action :authenticate_user!, only: [:edit, :update, :new, :create, :destroy]
  def index
    @posts=Post.all
    if Post.all.count > 2
      @ids = REDIS.zrevrangebyscore "post", "+inf", 0, limit: [0, 3]
    else
      @ids = REDIS.zrevrangebyscore "post", "+inf", 0, limit: [0, Post.all.count]
    end
  end

  def show
    @post=Post.find(params[:id])
    REDIS.zincrby "post", 1, @post.id
    if Post.all.count > 2
      @ids = REDIS.zrevrangebyscore "post", "+inf", 0, limit: [0, 3]
    else
      @ids = REDIS.zrevrangebyscore "post", "+inf", 0, limit: [0, Post.all.count]
    end
  end

  def edit
    @post=Post.find(params[:id])
  end

  def update
    if Post.find(params[:id]).update_attributes(post_params)
      redirect_to post_path(params[:id])
    else
      render 'edit'
    end
  end

  def new
    @post=current_user.posts.build
  end

  def create
    @post=current_user.posts.new(post_params)
    if @post.save
      redirect_to post_path(@post.id)
    else
      render 'new'
    end
  end

  def destroy
    Post.find(params[:id]).destroy
    REDIS.zrem "post", params[:id]
    redirect_to root_path
  end

  private
    def post_params
      params.require(:post).permit(:title, :content)
    end

    def user_correct
      if Post.find(params[:id]).user != current_user
        flash[:danger]="Not Yours"
        redirect_to root_url
      end
    end
end
