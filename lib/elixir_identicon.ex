defmodule ElixirIdenticon do
  @moduledoc """
  Documentation for `ElixirIdenticon`.
  """

  @doc """
  Generates an identicon from the given input (string).
  Identicon is saved in images directory under the passed input.
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

  @doc """
  Hashes the input and returns an image struct with a seed.
  """
  defp hash_input(input) do
    seed =
      :crypto.hash(:sha256, input)
      |> :binary.bin_to_list

    %ElixirIdenticon.Image{seed: seed}
  end

  @doc """
  Adds a color to the image struct, based on the first 3 values of the seed.
  """
  def set_color(image) do
    [r, g, b | _tail] = image.seed # %ElixirIdenticon.Image{seed: [r, g, b | _]) = image
    %ElixirIdenticon.Image{image | color: %{red: r, green: g, blue: b}}
  end

  @doc """
  Generates a grid of 7x4, based on the seed. Adds the index to each value. Returns an image struct with the new grid.
  """
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

  @doc """
  Generates a grid of 7x7, miroring horizonatly the first 3 values in each row.
  """
  def mirror_row(row) do
    [num1, num2, num3 | _tail] = row
    row ++ [num3, num2, num1]
  end

  @doc """
  Normalzies the grid by removing all enums with odd values.
  """
  def normalize_grid(image) do
    grid =
      image.grid
      |> Enum.filter( fn({val, _index}) -> rem(val, 2) == 0 end)

    %ElixirIdenticon.Image{image | grid: grid}
  end

  @doc """
  Creates a pixel map based on the grid. Returns an image struct with the new pixel map.
  """
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

  @doc """
  Draws an image based on the pixel map. Returns a binary.
  """
  def draw_image(%ElixirIdenticon.Image{color: color, pixel_map: pixel_map }) do
    canvas = :egd.create(700, 700)
    color = :egd.color({color.red, color.green, color.blue})

    Enum.each pixel_map, fn({{x1, y1}, {x2, y2}}) ->
      :egd.filledRectangle(canvas, {x1, y1}, {x2, y2}, color)
    end

    :egd.render(canvas)
  end

  @doc """
  Saves image from memory to the file.
  """
  def save(image, name) do
    File.write!("images/#{name}.png", image)
  end
end
