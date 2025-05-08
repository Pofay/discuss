defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  alias Discuss.{Topic, Comment}

  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)

    topic = Topic
    |> Repo.get(topic_id)
    # The preload function is used to load associated data
    # In this case it loads the comments associated with the topic
    |> Repo.preload(:comments)


    # socket behaves a lot like conn
    # where you can perform assign(socket, :key, value)
    # and then access it later with socket.assigns.key
    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in("comments:add", %{"content" => content}, socket) do
    # Get the topic from the socket assigns
    # Just like with conn.assigns
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    changeset =
      topic
      |> build_assoc(:comments, user_id: user_id)
      |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  def handle_in(name, message, socket) do
    {:reply, :ok, socket}
  end
end
