CREATE TABLE ipod_track (
  library int(10) not null,
  track int(10) not null,
  slimserverurl text not null,
  musicbrainz_id varchar(40),
  ipodpath varchar(511),
  ipodfilesize int(10),
  primary key (library,track)
) TYPE=InnoDB;

CREATE TABLE ipod_libraries (
  id int(10) not null AUTO_INCREMENT UNIQUE,
  libraryid varchar(255) not null,
  name varchar(255) not null,
  primary key (id)
) TYPE=InnoDB;
