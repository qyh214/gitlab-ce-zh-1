class Dashboard::TodosController < Dashboard::ApplicationController
  before_action :find_todos, only: [:index, :destroy_all]

  def index
    @sort = params[:sort]
    @todos = @todos.page(params[:page])
    if @todos.out_of_range? && @todos.total_pages != 0
      redirect_to url_for(params.merge(page: @todos.total_pages))
    end
  end

  def destroy
    TodoService.new.mark_todos_as_done_by_ids([params[:id]], current_user)

    respond_to do |format|
      format.html { redirect_to dashboard_todos_path, notice: '待办事项已完成。' }
      format.js { head :ok }
      format.json { render json: todos_counts }
    end
  end

  def destroy_all
    TodoService.new.mark_todos_as_done(@todos, current_user)

    respond_to do |format|
      format.html { redirect_to dashboard_todos_path, notice: '所有待办事项都已完成。' }
      format.js { head :ok }
      format.json { render json: todos_counts }
    end
  end

  private

  def find_todos
    @todos ||= TodosFinder.new(current_user, params).execute
  end

  def todos_counts
    {
      count: current_user.todos_pending_count,
      done_count: current_user.todos_done_count
    }
  end
end
