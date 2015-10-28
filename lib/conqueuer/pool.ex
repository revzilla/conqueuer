defmodule Conqueuer.Pool do
  @moduledoc """
  Use this mixin to define a poolboy pool and supervisor.

  Given you want a pool named `:workers`:

      defmodule MyApp.WorkerPool do
        use Conqueuer.Pool, name: :workers,
                            worker: MyApp.Worker,
                            size: 10,
                            max_overflow: 20
      end

  The `size` and `max_overflow` arguments are optional and if not provided the
  defaults are `size: 1` and `max_overflow: 0`.  For more information on these
  options please see the poolboy project's documentation.

  Now that the `:workers` pool and supervisor is defined you will need to add it to your
  supervision tree.
  """

  defmacro __using__(options) do
    quote do
      use Supervisor

      def start_link( args \\[], opts \\ [] ) do
        Supervisor.start_link __MODULE__, args, opts
      end

      def init([]) do
        pool_options = [
          name: {:local, name},
          worker_module: worker,
          size: size,
          max_overflow: max_overflow
        ]

        children = [
          :poolboy.child_spec(name, pool_options, [])
        ]

        supervise(children, strategy: :one_for_one)
      end

      defp name do
        unquote(options[:name])
      end

      defp max_overflow do
        unquote(options[:max_overflow] || 0)
      end

      defp size do
        unquote(options[:size] || 1)
      end

      defp worker do
        unquote(options[:worker])
      end
    end
  end
end