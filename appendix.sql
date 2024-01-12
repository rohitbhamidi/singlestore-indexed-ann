/* This appendix details the process of generating 160,000,000 vectors in a table in SingleStore, and then loading the Wikipedia video game data from our open AWS S3 
bucket into the same table. */

/* HELPER FUNCTIONS 
These functions are defined to help generate a random, normalized, 1536-dimensional vector. 1536 was chosen as the dimensionality because the OpenAI embeddings from 
text-ada-002 are of that dimension. */

set sql_mode = pipes_as_concat;

delimiter //
create or replace function randbetween(a float, b float) returns float
as 
begin
  return (rand()*(b - a) + a);
end //

create or replace function gen_vector(length int) returns text as
declare s text = "[";
begin
  if length < 2 then 
    raise user_exception("length too short: " || length);
  end if;

  for i in 1..length-1 loop
    s = s || randbetween(-1,1) || "," ;
  end loop;
  s = s || randbetween(-1,1) || "]";
  return s;
end //

create or replace function normalize(v blob) returns blob as
declare
  squares blob = vector_mul(v,v);
  length float = sqrt(vector_elements_sum(squares));
begin
  return scalar_vector_mul(1/length, v);
end //

create or replace function norm1536(v vector(1536)) returns vector(1536) as
begin
  return normalize(v);
end //

create or replace function nrandv1536() returns vector(1536) as
begin
  return norm1536(gen_vector(1536));
end  //
delimiter ;

/* GENERATING RANDOM VECTORS
This loop generates 160,000,000 random vectors of dimensionality 1536 directly in the below table. */

create table vecs(
id bigint(20),
url text default null,
paragraph text default null, 
v vector(1536) not null, 
shard key(id), 
key(id) using hash, 
fulltext (paragraph)
);

insert into vecs (id, v) values (1, nrandv1536());
delimiter //
do 
declare num_rows bigint = 160000000;
declare c int;
begin
  select count(*) into c from vecs;
  while c < num_rows loop
    insert into vecs
    select id + (select max(id) from vecs), nrandv1536()
    from vecs
    where id <= 128*1024; /* chunk size 128K so we can see progress */
    select count(*) into c from vecs;
  end loop;
end //
delimiter ;

/* LOADING WIKIPEDIA DATA
As mentioned above, we have the Wikipedia text data stored in a csv file in an open S3 bucket with URI ‘s3://wikipedia-video-game-data/video-game-embeddings(1).csv’. 
This pipeline code loads the data into a SingleStore table. */

-- since the bucket is open, you can leave the credentials clause as it is
create or replace pipeline `wiki_pipeline` as 
load data S3 's3://wikipedia-video-game-data/video-game-embeddings(1).csv' 
config '{"region":"us-west-1"}'
credentials '{"aws_access_key_id": "", 
            "aws_secret_access_key": ""}'
skip duplicate key errors
into table `vecs`
format csv
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n';


