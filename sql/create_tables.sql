 create table if not exists dim.dim_calendar
	as
		with dates as(
			select 
				dd::date as dt
			from generate_series(
				'2017-01-01'::timestamp, '2017-12-31'::timestamp, '1 day'::interval) dd)
		(select 
			to_char(dt, 'YYYYMMDD')::int as id,
			dt as date,
			date_part('isodow', dt)::int as day,
			date_part('month',dt)::int as month,
			date_part('isoyear',dt)::int as year,
			(date_part('isodow',dt)::smallint between 1 and 5)::int as work_day
		from dates
		order by dt)

alter table dim.dim_calendar add primary key(id);


create table if not exists dim.dim_passengers(
	id serial primary key,
	passenger_id varchar(20),
	passenger_name varchar(250),
	phone_number varchar(20),
	email varchar(250)
)


create table if not exists dim.dim_aircrafts(
	id serial primary key,
	aircraft_code varchar(3),
	model varchar(50),
	range int4,
	count_seats int4
)


create table if not exists dim.dim_airports(
	id serial primary key,
	airport_code varchar(3),
	airport_name varchar(50),
	longtitude float8,
	latitude float8,
	timezone varchar(50),
	city varchar(50)
)


create table if not exists dim.dim_tariff(
	id serial primary key,
	tariff_code varchar(10)
)


create table if not exists dim.fact_flights
(
    passenger_id             int  references dim.dim_passengers (id),
    actual_departure_dt      timestamp with time zone,
    actual_departure_date_id int  references dim.dim_calendar (id),
    actual_arrival_dt        timestamp with time zone,
    actual_arrival_date_id   int  references dim.dim_calendar (id),
    departure_delay          int,
    arrival_delay            int,
    aircraft_id              int  references dim.dim_aircrafts (id),
    departure_airport_id     int  references dim.dim_airports (id),
    arrival_airport_id       int  references dim.dim_airports (id),
    tariff_id                int  references dim.dim_tariff (id),
    amount                   numeric(10, 2)
);



create table if not exists dim.rejected_passengers(
	id serial primary key,
	passenger_id text,
	passenger_name text,
	phone_number text,
	email text,
    error text
)

create table if not exists dim.rejected_aircrafts(
	id serial primary key,
	aircraft_code text,
	model text,
	range int4,
	count_seats int4,
    error text
)

create table if not exists dim.rejected_airports(
	id serial primary key,
	airport_code text,
	airport_name text,
	longtitude float8,
	latitude float8,
	timezone text,
	city text,
    error text
)


create table if not exists dim.rejected_tariff(
	id serial primary key,
	tariff_code varchar(250),
	error text
)

create table if not exists dim.rejected_flights
(
    passenger_id             int,
    actual_departure_dt      timestamp with time zone,
    actual_departure_date_id int,
    actual_arrival_dt        timestamp with time zone,
    actual_arrival_date_id   int,
    departure_delay          int,
    arrival_delay            int,
    aircraft_id              int,
    departure_airport_id     int,
    arrival_airport_id       int,
    tariff_id                int,
    amount                   numeric(10, 2),
    error                   text
);