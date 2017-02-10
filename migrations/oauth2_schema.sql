-- 1 up
create table if not exists oauth2_client (
    id            varchar( 255 ) NOT NULL PRIMARY KEY,
    secret        varchar( 255 ) NOT NULL,
    active        boolean        NOT NULL DEFAULT true
);
insert into oauth2_client (id, secret) values ('zef_web_frontend', 'zef_web_frontend_secret');

-- 1 down
drop table if exists oauth2_client;