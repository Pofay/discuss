defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  def join(name, _params, socket) do
    {:ok, %{joined: "Sup"}, socket}
  end

  def handle_in(name, message, socket) do
    {:reply, :ok, socket}
  end
end
