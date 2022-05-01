defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list -> add_entry(todo_list, entry) end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def update_entry(todo_list, id, lambda) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = %{} = lambda.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def remove_entry(todo_list, key) do
    updated_entries = Map.delete(todo_list.entries, key)
    %TodoList{todo_list | entries: updated_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end

defmodule TodoList.CsvImporter do
  def import(path) do
    path 
    |> read_lines
    |> parse_entries
    |> evaluate
  end

  defp read_lines(filename) do
    filename
    |> File.stream!
    |> Enum.map(&String.replace(&1, "\n", ""))
  end

  defp parse_entries(line) do
    line
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(&create_entry(&1))
  end

  defp create_entry([string_date, title]) do
    date = format_date(string_date)
    %{date: date, title: title}
  end

  defp format_date(string_date) do
    [year, month, day] =
      String.split(string_date, "/")
      |> Enum.map(&String.to_integer/1)

      {:ok, date} = Date.new(year, month, day)
      date
  end

  defp evaluate(entries) do
    TodoList.new(entries)
  end
end
