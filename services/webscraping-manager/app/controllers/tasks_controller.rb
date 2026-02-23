class TasksController < ApplicationController
  before_action :authenticate_user!

  # GET /tasks
  def index
    # Filtra as tarefas pelo user_id extraído do cookie JWT
    @tasks = Task.where(user_id: current_user_id).order(created_at: :desc)
    render json: @tasks
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @task.user_id = current_user_id
    @task.status = 'pending'

    if @task.save
      # Chama o Solver de forma assíncrona (ou direta por enquanto)
      # Nota: Em produção, isso deveria ser um Background Job
      
      render json: @task, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :url)
  end
end