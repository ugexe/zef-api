-- 1 up
create table if not exists distributions (
    id          SERIAL         NOT NULL PRIMARY KEY,
    name        varchar( 255 ) NOT NULL,
    version     varchar( 255 ) NOT NULL,
    auth        varchar( 255 ) NOT NULL,
    meta        jsonb          NOT NULL
);

-- 1 down
drop table if exists distributions;