## Создание таблиц-измерений
### Таблица справочника дат (`Dim_Calendar`)
    Так как в базе данные хранятся с 2016 по 2017 год, то заполняем справочник за весь 2017 год. Итоговые данные будут иметь вид: дата, номер дня недели, месяц, год, выходной/рабочий день (1 - рабочий, 0 - выходной).
   
   ```sql
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
```

### Таблица справочника пассажиров (`Dim_Passengers`)
    Данные по пассажирам будут храниться в формате: id пассажира, ФИО, номер телефона и e-mail.
```sql
create table if not exists dim.dim_passengers(
	id serial primary key,
	passenger_id varchar(20),
	passenger_name varchar(250),
	phone_number varchar(20),
	email varchar(250)
)
```

### Таблица справочника самолетов (`Dim_Aircrafts`)
    Данные по самолетам будут храниться в формате: код самолета, модель, максимальная дальность полета, количество сидений.
```sql
create table if not exists dim.dim_aircrafts(
	id serial primary key,
	aircraft_code varchar(3),
	model varchar(50),
	range int4,
	count_seats int4
)
```

### Таблица справочника аэропортов (`Dim_Airports`)
    Данные по аэропортам будут храниться в формате: код аэропорта, название, долгота, широта, временная зона, город.
```sql
create table if not exists dim.dim_airports(
	id serial primary key,
	airport_code varchar(3),
	airport_name varchar(50),
	longtitude float8,
	latitude float8,
	timezone varchar(50),
	city varchar(50)
)
```

### Таблица справочник тарифов (`Dim_Tariff`)
    Данные по тарифам будут храниться по типу тарифа.
```sql
create table if not exists dim.dim_tariff(
	id serial primary key,
	tariff_code varchar(10)
)
```

## Создание таблицы фактов (`Fact_Flights`)

```sql
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
```


## Создание таблиц для ошибок (`rejected`)
    В данных таблицах будут храниться данные, не прошедшие проверку на качество. Помимо данных, таблицы будут содержать текст ошибки.

### Таблица для `dim_passengers` (`rejected_passengers`)
```sql
create table if not exists dim.rejected_passengers(
	id serial primary key,
	passenger_id text,
	passenger_name text,
	phone_number text,
	email text,
    error text
)
```

### Таблица для `dim_aircrafts` (`rejected_aircrafts`)
```sql
create table if not exists dim.rejected_aircrafts(
	id serial primary key,
	aircraft_code text,
	model text,
	range int4,
	count_seats int4,
    error text
)
```

### Таблица для `dim_airports` (`rejected_airports`)
```sql 
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
```

### Таблица для `dim_tariff` (`rejected_tariff`)
```sql
create table if not exists dim.rejected_tariff(
	id serial primary key,
	fare_conditions varchar(250),
	error text
)
```

### Таблица для `Fact_Flights` (`rejected_flights`)
```sql
create table if not exists dim.rejected_flights
(
    passenger_id             varchar(200),
    actual_departure_dt      timestamp with time zone,
    actual_departure_date_id varchar(200),
    actual_arrival_dt        timestamp with time zone,
    actual_arrival_date_id   varchar(200),
    departure_delay          varchar(200),
    arrival_delay            varchar(200),
    aircraft_id              varchar(200),
    departure_airport_id     varchar(200),
    arrival_airport_id       varchar(200),
    tariff_id                varchar(200),
    amount                   numeric(10, 2),
    error                   text
);
```