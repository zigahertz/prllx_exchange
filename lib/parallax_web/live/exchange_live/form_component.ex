defmodule ParallaxWeb.ExchangeLive.FormComponent do
  use ParallaxWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>

      </.header>

      <.simple_form
        for={@form}
        id="order-form"
        phx-target={@myself}
        phx-change="calculate"
        phx-submit="execute"
      >
        Convert
        <.input field={@form[:from_amount]} type="number" phx-debounce="200" /> in <%= @from %>
        to <%= @amount %> <%= @to %>

        <br>

        Rate: <%= @rate %>
        <:actions>
          <.button phx-disable-with="Executing...">Execute</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{quote_attrs: attrs} = assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:from, String.upcase(attrs.from_currency))
      |> assign(:to, String.upcase(attrs.to_currency))
      |> assign(:rate, attrs.rate)
      |> assign_form()
      |> assign(:amount, nil)
    }
  end

  @impl true
  def handle_event("calculate", %{"from_amount" => from_amount}, socket) do
    case Float.parse(from_amount) do
      :error ->
        {:noreply, socket}
      {from, _} ->
        {rate, _} = Float.parse(socket.assigns.rate)
        amount = Float.round(rate * from, 4)
        {:noreply, assign(socket, :amount, amount)}
    end
  end

  @impl true
  def handle_event("execute", %{"from_amount" => from_amount}, socket) do
    # require IEx; IEx.pry
    {:noreply, socket}
    # save_quotes(socket, socket.assigns.action, quotes_params)
  end

  defp assign_form(socket) do
    assign(socket, :form, to_form(%{"from_amount" => 0}))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
