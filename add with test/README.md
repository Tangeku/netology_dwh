## Описание работы ETL

### Работа с таблицами-измерений
>Все ETL, связанные с таблицами измерений строятся по следующему принципу:
1. `Получение данных из исходных таблиц`
2. `Проверка корректности данных по` [условиям качества](https://github.com/Tangeku/netology_dwh/tree/main/errors)
3. `Выгрузка ошибочных данных в rejected-таблицы с текстом ошибки` \
3.1. `Данные, прошедшие проверку, выгружаются в соответствующие таблицы`

### Таблица фактов
>Таблица `Fact_Flights` собирается по следующему принципу:
1. `Получение данных из исходной таблицы соответствующим запросом`
```sql
select 
	t.passenger_id as passenger_id,
	f.actual_departure as actual_departure_dt,
	TO_CHAR(f.actual_departure, 'YYYYMMDD')::int as actual_departure_date_id,
	f.actual_arrival as actual_arrival_dt,
    TO_CHAR(f.actual_arrival, 'YYYYMMDD')::int as actual_arrival_date_id,	
	EXTRACT(EPOCH FROM f.actual_departure) - EXTRACT(EPOCH FROM f.scheduled_departure) as departure_delay,
	EXTRACT(EPOCH FROM f.actual_arrival) -   EXTRACT(EPOCH FROM f.scheduled_arrival) as arrival_delay,
	f.aircraft_code as aircraft_id,
	f.departure_airport as departure_airport_id,                                                               
    f.arrival_airport as arrival_airport_id,
    tf.fare_conditions as tariff_id,                                                       
    tf.amount,
	f.actual_departure::date as dim_date
from bookings.flights f
           join bookings.ticket_flights tf on tf.flight_id = f.flight_id
           join bookings.tickets t on t.ticket_no = tf.ticket_no
 where f.actual_arrival is not null
   and f.status = 'Arrived';
```
2. `Проверка корректности данных по` [условиям качества](https://github.com/Tangeku/netology_dwh/tree/main/errors)
3. `Выгрузка ошибочных данных в rejected-таблицу с текстом ошибки`
4. `Данные, прошедшие проверку, ссылаются на соответствующие таблицы-измерений`\
4.1. `Данные для измерения по датам приведены в формат без времени`
5. `Данные выгружаются в соответствующую таблицу`


### Описание Job
>Job выполняет функцию последовательной загрузки для таблиц:
таблица фактов запустится только после таблицы измерений.