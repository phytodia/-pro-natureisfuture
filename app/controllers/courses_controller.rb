class CoursesController < ApplicationController
  def index

  end
  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.save
  end

  def show
    @cours = Course.find(params[:id])
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def course_params
    params.require(:course).permit(:titre,:introduction)
  end
end
