defmodule MessengerWeb.RoomLive do
  use MessengerWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id},_session, socket) do
    topic = "room" <> room_id
    if connected?(socket), do: MessengerWeb.Endpoint.subscribe(topic)

  {:ok,
    assign(socket,
      room_id: room_id,
      message: "",
      topic: topic,
      messages: [%{ uuid: UUID.uuid4(), content: "Hello Fábio"}],
      temporary_assigns: [messages: []]
    )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message}
    MessengerWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(payload: message)
    {:noreply, assign(socket, messages: [message])}
  end
end
