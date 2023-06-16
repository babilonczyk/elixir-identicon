defmodule ElixirIdenticon do
  @moduledoc """
  Documentation for `ElixirIdenticon`.
  """

  def generate(input) do
    input
    |> hash_input
    |> set_color
    |> generate_grid
    |> normalize_grid
    |> generate_pixel_map
    |> draw_image
    |> save(input)
  end

  defp hash_input(input) do
    seed =
      :crypto.hash(:sha256, input)
      |> :binary.bin_to_list

    %ElixirIdenticon.Image{seed: seed}
  end

  def set_color(image) do
    [r, g, b | _tail] = image.seed # %ElixirIdenticon.Image{seed: [r, g, b | _]) = image
    %ElixirIdenticon.Image{image | color: %{red: r, green: g, blue: b}}
  end

  def generate_grid(image) do
    grid =
      image.seed
      |> Enum.chunk_every(4)
      |> Enum.slice(0,7)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [num1, num2, num3 | _tail] = row
    row ++ [num3, num2, num1]
  end

  def normalize_grid(image) do
    grid =
      image.grid
      |> Enum.filter( fn({val, _index}) -> rem(val, 2) == 0 end)

    %ElixirIdenticon.Image{image | grid: grid}
  end

  def generate_pixel_map(image) do
    pixel_map = Enum.map image.grid, fn({_val, index}) ->
        x = rem(index,7) * 100
        y = div(index,7) * 100

        {
          {x, y},
          {x + 100, y + 100}
        }
      end
    %ElixirIdenticon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%ElixirIdenticon.Image{color: color, pixel_map: pixel_map }) do
    canvas = :egd.create(700, 700)
    color = :egd.color({color.red, color.green, color.blue})

    Enum.each pixel_map, fn({{x1, y1}, {x2, y2}}) ->
      :egd.filledRectangle(canvas, {x1, y1}, {x2, y2}, color)
    end

    :egd.render(canvas)
  end

  def save(image, name) do
    File.write!("images/#{name}.png", image)
  end
end
