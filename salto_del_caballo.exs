defmodule SaltoDelCaballo do
  @board_size 8

  @moves [
    {2, 1}, {1, 2}, {-1, 2}, {-2, 1},
    {-2, -1}, {-1, -2}, {1, -2}, {2, -1}
  ]

  def solve do
    # Crear tablero lleno de -1
    board = for _ <- 1..@board_size, do: Enum.map(1..@board_size, fn _ -> -1 end)

    # Marcar la casilla inicial (0,0) como 0
    board = update_board(board, 0, 0, 0)

    case solve_knight(board, 0, 0, 1) do
      {:ok, solution} ->
        print_board(solution)

      :fail ->
        IO.puts("No se encontró solución.")
    end
  end

  # Caso base: todas las casillas visitadas
  defp solve_knight(board, _x, _y, step) when step == @board_size * @board_size do
    {:ok, board}
  end

  # Caso recursivo
  defp solve_knight(board, x, y, step) do
    Enum.reduce_while(@moves, :fail, fn {dx, dy}, _acc ->
      new_x = x + dx
      new_y = y + dy

      if valid_move?(board, new_x, new_y) do
        new_board = update_board(board, new_x, new_y, step)

        case solve_knight(new_board, new_x, new_y, step + 1) do
          {:ok, solution} -> {:halt, {:ok, solution}}
          :fail -> {:cont, :fail}
        end
      else
        {:cont, :fail}
      end
    end)
  end

  # Actualiza una posición en el tablero
  defp update_board(board, x, y, value) do
    List.update_at(board, x, fn row ->
      List.update_at(row, y, fn _ -> value end)
    end)
  end

  # Verifica si un movimiento es válido
  defp valid_move?(board, x, y) do
    x >= 0 and y >= 0 and x < @board_size and y < @board_size and
      Enum.at(Enum.at(board, x), y) == -1
  end

  # Imprime el tablero formateado
  defp print_board(board) do
    Enum.each(board, fn row ->
      row
      |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))
      |> Enum.join(" ")
      |> IO.puts()
    end)
  end
end

SaltoDelCaballo.solve()
