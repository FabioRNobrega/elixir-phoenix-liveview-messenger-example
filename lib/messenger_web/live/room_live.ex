defmodule MessengerWeb.RoomLive do
  use MessengerWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id},_session, socket) do
    topic = "room" <> room_id
    user_name = MnemonicSlugs.generate_slug(2)
    if connected?(socket) do
      MessengerWeb.Endpoint.subscribe(topic)
      MessengerWeb.Presence.track(self(), topic, user_name, %{})
    end


  {:ok,
    assign(socket,
      room_id: room_id,
      user_name: user_name,
      message: "",
      topic: topic,
      messages: [],
      user_list: [],
      temporary_assigns: [messages: []]
    )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, user_name: socket.assigns.user_name}
    MessengerWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do

    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn user_name ->
        %{ type: :system, uuid: UUID.uuid4(), content: "#{user_name} joined" }
      end)

    leaves_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn user_name ->
        %{ type: :system, uuid: UUID.uuid4(), content: "#{user_name} left" }
      end)

      user_list = MessengerWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

    {:noreply, assign(socket, messages: join_messages ++ leaves_messages, user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
     <p id={<%= uuid %>}> <em> <%= content %> </em> </p>
    """
  end

  def display_message(assigns) do
    ~H"""
      <p id={@uuid}> <strong> <%= @user_name %>: </strong> <%= @content %> </p>
    """
  end
end
