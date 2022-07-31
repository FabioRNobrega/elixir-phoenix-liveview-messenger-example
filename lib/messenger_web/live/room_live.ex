defmodule MessengerWeb.RoomLive do
  use MessengerWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id},_session, socket) do
    Logger.info(room_id)
    {:ok,  assign(socket, room_id: room_id)}
  end
end
