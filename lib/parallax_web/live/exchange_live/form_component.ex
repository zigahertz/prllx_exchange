defmodule ParallaxWeb.ExchangeLive.FormComponent do
  use ParallaxWeb, :live_component
  alias Parallax.Exchange
  alias Exchange.{Quote, Order}

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
        <.input field={@form[:from_amount]} type="number" phx-debounce="100" /> in <%= @from %>
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
      |> assign(:amount, nil)
      |> assign_form()
    }
  end

  @impl true
  def handle_event("calculate", %{"from_amount" => from_amount}, socket) do
    case Float.parse(from_amount) do
      :error ->
        {:noreply, put_flash(socket, :info, "amount must be a float")}
      {from, _} ->
        {rate, _} = Float.parse(socket.assigns.rate)
        amount = Float.round(rate * from, 4)
        {:noreply, assign(socket, :amount, amount)}
    end
  end

  @impl true
  def handle_event("execute", %{"from_amount" => from_amount}, socket) do
    %{user_id: user_id, id: quote_id} = socket.assigns

    with %Order{id: order_id} <- Exchange.create_order(user_id, quote_id, from_amount),
         {pid, _} <- Exchange.lookup_quote(quote_id),
         :ok <- Quote.update(pid, [status: :expired]) do
      {:noreply, push_navigate(socket, to: ~p"/u/#{user_id}/orders/#{order_id}")}
    else
      _ -> {:noreply, socket}
    end
  end

  defp assign_form(socket) do
    assign(socket, :form, to_form(%{"from_amount" => 1.08}))
  end

end
