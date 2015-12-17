BEGIN;

    --even though the spec seems to always use the same graph, it does
    -- say each graph has an id, so make the db work that way, and it's
    -- no extra work to make it support multiple, and makes it more useful

    --why varchar(128)? there has to be a limit, and the spec doesn't say,
    -- so it's as good as anything

    --i'd normally give every table a serial id as the PK, but i've decided
    -- it doesn't add any value here, and will make the code more complex,
    -- as lookups are always clearest when done with the PK, which will be
    -- the provided id. 

    --nothing is mentioned about names being unique or used for lookups,
    -- so i'm going to assume they're descriptive only

    CREATE TABLE graphs (
        "id"      varchar(128) NOT NULL,  --user provided id
        "name"    varchar(128) NOT NULL,  --user provided name
        PRIMARY KEY ("id")
    );

    CREATE TABLE nodes (
        "id"          varchar(128) NOT NULL,  --user provided id
        "graph_id"    varchar(128) NOT NULL,  --points to graphs.id
        "name"        varchar(128) NOT NULL,  --user provided name
        PRIMARY KEY ("id", "graph_id")        --we need the graph_id to lookup the node, and auto unique
    );

    --this is so we can find the nodes of a graph
    ALTER TABLE "nodes" ADD CONSTRAINT "nodes-graph" FOREIGN KEY ("graph_id")
        REFERENCES "graphs" ("id");

    CREATE TABLE edges (
        "id"          varchar(128) NOT NULL,                 --user provided id
        "graph_id"    varchar(128) NOT NULL,                 --points to a graphs.id
        "to"          varchar(128) NOT NULL,                 --this point's to nodes.id
        "from"        varchar(128) NOT NULL,                 --this point's to nodes.id
        "cost"        float CHECK ( "cost" >= 0 ) DEFAULT 0, --optional cost >= 0
        PRIMARY KEY ("id", "graph_id"),
        CONSTRAINT "edges-graph_id-to-from:unique" UNIQUE ("graph_id", "to", "from")
    );
    --this is so we can find the edges of a graph
    ALTER TABLE "edges" ADD CONSTRAINT "edges-graph" FOREIGN KEY ("graph_id")
        REFERENCES "graphs" ("id");

    --this is for looking up the "to" part of the edge, so we can build the result
    ALTER TABLE "edges" ADD CONSTRAINT "edges-graph-to" FOREIGN KEY ("graph_id", "to")
        REFERENCES "nodes" ("graph_id", "id");

    --this is for looking up the "from" part of the edge, so we can build the result
    ALTER TABLE "edges" ADD CONSTRAINT "edges-graph-from" FOREIGN KEY ("graph_id", "from")
        REFERENCES "nodes" ("graph_id", "id");

COMMIT;
