defmodule TodoList do

    defstruct auto_id: 1, entries: %{} 

    def new(), do: %TodoList{}

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            fn entry, todo_list -> add_entry(todo_list, entry) end
        )
    end

    def add_entry(todo_list, entry) do
        entry = Map.put(entry, :id, todo_list.auto_id)

        new_entries = Map.put(
            todo_list.entries,
            todo_list.auto_id,
            entry
        )

        %TodoList{todo_list |
            entries: new_entries, 
            auto_id: todo_list.auto_id + 1
        }
    end

    def update_entry(todo_list, id, lambda) do
        case Map.fetch(todo_list.entries, id) do
            :error -> todo_list

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
        todo_list.entries |> 
            Stream.filter(fn {_, entry} -> entry.date == date end) |>
            Enum.map(fn {_, entry} -> entry end)
    end
end