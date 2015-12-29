-- When I went looking at the documentation for WITH there was an example there
-- that did pretty much what I wanted, so I used it to write this.

-- I don't think that's cheating, part of the job is to research things and use
-- that information to solve the problem

WITH RECURSIVE find_cycles( "from", "to", "path", "cycle" ) AS (
        SELECT
            first."from",
            first."to",
            ARRAY[CAST( first."from" as text ), CAST( first."to" as text )],
            false,
            first."graph_id"
        FROM
            edges first
    UNION ALL
        SELECT
            next."from",
            next."to",
            previous."path" || CAST( next."to" as text ),
            next."to" = ANY(path),
            next."graph_id"
        FROM
            edges next, find_cycles previous
        WHERE
            next."from" = previous."to"
            AND next."graph_id" = previous."graph_id"
            AND NOT "cycle"
            AND next.graph_id = 'g0'
)

-- this find the cycles in the graph, not all the paths that have cycles, for
-- that remove the last part
-- it searches 
SELECT * FROM find_cycles WHERE cycle AND path[1] = path[array_length(path, 1)];
