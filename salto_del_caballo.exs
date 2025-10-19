defmodule SaltoDelCaballo do
  # Tamaño del tablero (8x8 típico)
  @board_size 8

  # Listado de los 8 movimientos posibles del caballo como parejas (dx, dy).
  # Estos son vectores que se suman a la posición actual para obtener la nueva casilla.
  @moves [
    {2, 1}, {1, 2}, {-1, 2}, {-2, 1},
    {-2, -1}, {-1, -2}, {1, -2}, {2, -1}
  ]

  # Punto de entrada público que lanza la solución.
  # 1) Crea el tablero inicial (matriz) lleno de -1 indicando "no visitado".
  # 2) Marca la casilla inicial (0,0) con el paso 0.
  # 3) Llama al algoritmo recursivo que intenta completar el tablero.
  # 4) Imprime la solución si la encuentra o un mensaje si no hay solución.
  def resolver do
    # Crear un tablero (lista de filas) donde cada casilla vale -1 (no visitada).
    board = for _ <- 1..@board_size, do: Enum.map(1..@board_size, fn _ -> -1 end)

    # Marcar la casilla inicial (0,0) con el primer paso, 0.
    board = update_board(board, 0, 0, 0)

    # Lanzar la búsqueda backtracking desde (0,0) con el siguiente paso igual a 1.
    case solve_knight(board, 0, 0, 1) do
      {:ok, solution} ->
        # Si devuelve {:ok, board} imprimimos el tablero resultante.
        print_board(solution)

      :fail ->
        IO.puts("No se encontró solución.")
    end
  end

  # --------------------------------------------------
  # Caso base para la recursión (condición de éxito):
  # Si 'step' alcanza board_size * board_size entonces todas las casillas
  # han sido visitadas (pasos desde 0 hasta n-1). Devolver {:ok, board}.
  # --------------------------------------------------
  defp solve_knight(board, _x, _y, step) when step == @board_size * @board_size do
    {:ok, board}
  end

  # --------------------------------------------------
  # Caso recursivo: intentar cada movimiento posible desde (x,y)
  # - Recorremos @moves con Enum.reduce_while para permitir cortar la búsqueda
  #   cuando encontremos una solución (halt).
  # - Para cada movimiento válido:
  #     * Actualizamos el tablero marcando la casilla con el número de paso.
  #     * Llamamos recursivamente con step+1.
  #     * Si la llamada recursiva devuelve {:ok, solution} propagamos ese resultado
  #       hacia arriba con {:halt, {:ok, solution}}.
  #     * Si la llamada recursiva devuelve :fail, continuamos probando el siguiente movimiento.
  # - Si ningún movimiento lleva a una solución devolvemos :fail.
  # --------------------------------------------------
  defp solve_knight(board, x, y, step) do
    Enum.reduce_while(@moves, :fail, fn {dx, dy}, _acc ->
      new_x = x + dx
      new_y = y + dy

      # Comprobar si el nuevo movimiento está dentro del tablero y no ha sido visitado.
      if valid_move?(board, new_x, new_y) do
        # Marcar el nuevo paso en la copia del tablero
        new_board = update_board(board, new_x, new_y, step)

        # Llamada recursiva
        case solve_knight(new_board, new_x, new_y, step + 1) do
          {:ok, solution} ->
            # Si se encontró solución, detenemos la reducción y la devolvemos
            {:halt, {:ok, solution}}

          :fail ->
            # Este camino no funcionó, seguimos probando otros movimientos
            {:cont, :fail}
        end
      else
        # Movimiento inválido: fuera de rango o casilla ya visitada
        {:cont, :fail}
      end
    end)
  end

  # --------------------------------------------------
  # update_board/4
  # Actualiza el tablero en la posición (x, y) con el valor indicado.
  # Entrada:
  #   - board: lista de filas (cada fila es una lista)
  #   - x, y: índices (0-based)
  #   - value: valor numérico a escribir (p. ej. número de paso)
  # Salida: tablero nuevo con la posición actualizada
  # --------------------------------------------------
  defp update_board(board, x, y, value) do
    List.update_at(board, x, fn row ->
      List.update_at(row, y, fn _ -> value end)
    end)
  end

  # --------------------------------------------------
  # valid_move?/3
  # Verifica si una coordenada (x,y) está dentro del tablero y no ha sido visitada.
  # Se asume indexación 0..(@board_size-1).
  # --------------------------------------------------
  defp valid_move?(board, x, y) do
    x >= 0 and y >= 0 and x < @board_size and y < @board_size and
      Enum.at(Enum.at(board, x), y) == -1
  end

  # --------------------------------------------------
  # print_board/1
  # Imprime el tablero de forma legible para una presentación.
  # Cada número se convierte a cadena y se rellena a 2 dígitos para alineación.
  # --------------------------------------------------
  defp print_board(board) do
    Enum.each(board, fn row ->
      row
      |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))
      |> Enum.join(" ")
      |> IO.puts()
    end)
  end
end

# Llamada final que inicia la ejecución del módulo.
SaltoDelCaballo.resolver()
