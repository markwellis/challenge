WITH RECURSIVE walk( "id", "from", "to", "path", "cycle" ) AS (
        SELECT
            first."id",
            first."from",
            first."to",
            ARRAY[CAST( first."from" as text ), CAST( first."to" as text )],
            false,
            first."graph_id"
        FROM
            edges first
    UNION ALL
        SELECT
            next."id",
            next."from",
            next."to",
            previous."path" || CAST( next."to" as text ),
            next."to" = ANY(path),
            next."graph_id"
        FROM
            edges next, walk previous
        WHERE
            next."from" = previous."to"
            AND next."graph_id" = previous."graph_id"
            AND NOT "cycle"
)
SELECT * FROM walk WHERE cycle AND graph_id = 'g0';
