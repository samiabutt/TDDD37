/* Drop all tables */
DROP TABLE IF EXISTS `contact_responsible`;
DROP TABLE IF EXISTS `passenger_ticket`;
DROP TABLE IF EXISTS `reserved_on`;
DROP TABLE IF EXISTS `contact`;
DROP TABLE IF EXISTS `passenger`;
DROP TABLE IF EXISTS `booking`;
DROP TABLE IF EXISTS `credit_card`;
DROP TABLE IF EXISTS `reservation`;
DROP TABLE IF EXISTS `flight`;
DROP TABLE IF EXISTS `weekly_schedule`;
DROP TABLE IF EXISTS `route`;
DROP TABLE IF EXISTS `airport`;
DROP TABLE IF EXISTS `weekday`;
DROP TABLE IF EXISTS `year`;

/* Drop all procedures */
DROP PROCEDURE IF EXISTS `addYear`;
DROP PROCEDURE IF EXISTS `addDay`;
DROP PROCEDURE IF EXISTS `addDestination`;
DROP PROCEDURE IF EXISTS `addRoute`;
DROP PROCEDURE IF EXISTS `addFlight`;

DROP PROCEDURE IF EXISTS `addReservation`;
DROP PROCEDURE IF EXISTS `addPassenger`;
DROP PROCEDURE IF EXISTS `addContact`;
DROP PROCEDURE IF EXISTS `addPayment`;

/* Drop all functions */
DROP FUNCTION IF EXISTS `calculateFreeSeats`;
DROP FUNCTION IF EXISTS `calculatePrice`;
DROP FUNCTION IF EXISTS `calculateBookedSeats`;

/* Drop all views */
DROP VIEW IF EXISTS `allFlights`;

/* Create the tables from the relational model */


CREATE TABLE `passenger` (
    `passport_number` INT NOT NULL,
    `name` VARCHAR(30),
    PRIMARY KEY `pk_passport_number`(`passport_number`)
);


CREATE TABLE `contact` (
    `passport_number` INT NOT NULL,
    `email` VARCHAR(30),
    `phone_number` BIGINT NOT NULL,
    PRIMARY KEY `pk_passport_number`(`passport_number`),
    CONSTRAINT `fk_contact_passenger`
        FOREIGN KEY (`passport_number`)
        REFERENCES `passenger` (`passport_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `year` (
    `year` INT NOT NULL,
    `profit_factor` DOUBLE NOT NULL,
    PRIMARY KEY `pk_year`(`year`)
);


CREATE TABLE `weekday` (
    `name` VARCHAR(10),
    `year` INT NOT NULL,
    `pricing_factor` DOUBLE NOT NULL,
    PRIMARY KEY `pk_name_year`(`name`, `year`),
    CONSTRAINT `fk_weekday_year`
        FOREIGN KEY (`year`)
        REFERENCES `year` (`year`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `airport` (
    `airport_code` VARCHAR(3),
    `airport_name` VARCHAR(30),
    `country` VARCHAR(30),
    `city_name` VARCHAR(30),
    PRIMARY KEY `pk_airport_code`(`airport_code`)
);


CREATE TABLE `route` (
    `departure` VARCHAR(3) NOT NULL,
    `arrival` VARCHAR(3) NOT NULL,
    `price` DOUBLE,
    `year` INT NOT NULL,
    PRIMARY KEY `pk_dep_arr`(`departure`, `arrival`, `year`),
    CONSTRAINT `fk_route_airport`
        FOREIGN KEY (`departure`)
        REFERENCES `airport` (`airport_code`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_airport_airport`
        FOREIGN KEY (`arrival`)
        REFERENCES `airport` (`airport_code`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_route_year`
        FOREIGN KEY (`year`)
        REFERENCES `year` (`year`)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);


CREATE TABLE `weekly_schedule` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `departure_time` TIME,
    `year` INT NOT NULL,
    `weekday` VARCHAR(10) NOT NULL,
    `departure` VARCHAR(3) NOT NULL,
    `arrival` VARCHAR(3) NOT NULL,
    `route_year` INT NOT NULL,
    PRIMARY KEY `pk_id`(`id`),
    CONSTRAINT `fk_weekday_sched_weekday`
        FOREIGN KEY (`year`)
        REFERENCES `weekday` (`year`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_weekday_weekday`
        FOREIGN KEY (`weekday`)
        REFERENCES `weekday` (`name`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_weekday_1_route`
        FOREIGN KEY (`departure`)
        REFERENCES `route` (`departure`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_weekday_2_route`
        FOREIGN KEY (`arrival`)
        REFERENCES `route` (`arrival`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_weekly_schedule_year`
        FOREIGN KEY (`route_year`)
        REFERENCES `route` (`year`)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);


CREATE TABLE `flight` (
    `flight_number` INT NOT NULL AUTO_INCREMENT,
    `week` INT NOT NULL,
    `weekly_flight` INT NOT NULL,
    PRIMARY KEY `pk_flight_number`(`flight_number`),
    CONSTRAINT `fk_flight_weekly_schedule`
        FOREIGN KEY (`weekly_flight`)
        REFERENCES `weekly_schedule` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `credit_card` (
	`ccn` BIGINT NOT NULL,
	`name` VARCHAR(30),
	PRIMARY KEY `pk_ccn`(`ccn`)
);


CREATE TABLE `reservation` (
    `reservation_number` INT NOT NULL AUTO_INCREMENT,
    `num_seats_reserved` INT NOT NULL,
    `flight` INT NOT NULL,
    PRIMARY KEY `pk_reservation_number`(`reservation_number`),
    CONSTRAINT `fk_reservation_flight`
        FOREIGN KEY (`flight`)
        REFERENCES `flight` (`flight_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `booking` (
    `reservation_number` INT NOT NULL,
    `price` DOUBLE NOT NULL,
    `credit_card` BIGINT NOT NULL,
    PRIMARY KEY `pk_reservation_number`(`reservation_number`),
    CONSTRAINT `fk_booking_reservation`
        FOREIGN KEY (`reservation_number`)
        REFERENCES `reservation` (`reservation_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_booking_credit_card`
        FOREIGN KEY (`credit_card`)
        REFERENCES `credit_card` (`ccn`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `contact_responsible` (
    `contact` INT NOT NULL,
    `reservation` INT NOT NULL,
    PRIMARY KEY `pk_contact_reservation`(`contact`, `reservation`),
    CONSTRAINT `fk_cr_contact`
        FOREIGN KEY (`contact`)
        REFERENCES `contact` (`passport_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_cr_reservation`
        FOREIGN KEY (`reservation`)
        REFERENCES `reservation` (`reservation_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `passenger_ticket` (
    `passenger` INT NOT NULL,
    `booking` INT NOT NULL,
    `ticket_no` INT,
    PRIMARY KEY `pk_passenger_booking`(`passenger`, `booking`),
    CONSTRAINT `fk_pt_passenger`
        FOREIGN KEY (`passenger`)
        REFERENCES `passenger` (`passport_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_pt_booking`
        FOREIGN KEY (`booking`)
        REFERENCES `booking` (`reservation_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE `reserved_on` (
    `passenger` INT NOT NULL,
    `reservation` INT NOT NULL,
    PRIMARY KEY `pk_passenger_reservation`(`passenger`, `reservation`),
    CONSTRAINT `fk_ro_passenger`
        FOREIGN KEY (`passenger`)
        REFERENCES `passenger` (`passport_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_ro_reservation`
        FOREIGN KEY (`reservation`)
        REFERENCES `reservation` (`reservation_number`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


/*
Create Procedures and functions.
*/

delimiter //

CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
	INSERT INTO year VALUES(year, factor);
END //


CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO weekday VALUES(day, year, factor);
END //


CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
	INSERT INTO airport (airport_code, city_name, country) 
        VALUES(airport_code, name, country);
END //


CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
	IN year INT, IN routeprice DOUBLE)
BEGIN
	INSERT INTO route (departure, arrival, price, year) 
        VALUES(departure_airport_code, arrival_airport_code, routeprice, year);
END //


/* A procedure that adds a flight to the weekly schedule */
CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
    /* Declare loop counter and a variable to keep track of the schedule that corresponds
    to the flights */
    DECLARE loop_counter INT DEFAULT 0;
    DECLARE weekly_flight_id INT;

    /* Insert the weekly flight into the schedule. */
	INSERT INTO weekly_schedule (departure_time, year, weekday, departure, arrival, route_year) 
	    VALUES(departure_time, year, day, departure_airport_code, arrival_airport_code, year);
	SET weekly_flight_id = LAST_INSERT_ID();

    /* Instantiate the weekly_flight once for each week in the year (52 weeks) */
	WHILE loop_counter < 52 DO
	    SET loop_counter = loop_counter + 1;
	    INSERT INTO flight (week, weekly_flight) 
		VALUES(loop_counter, weekly_flight_id);
	END WHILE;
END //


CREATE FUNCTION `calculateBookedSeats`(`flightnumber` INT) RETURNS INT
BEGIN
    /* The number of booked seats in a flight is equal to the number of ticket numbers
    that corresponds to a the flight number */
    RETURN (SELECT COUNT(*) FROM flight 
                JOIN `reservation` res ON flight.flight_number = res.flight 
                JOIN booking ON booking.reservation_number = res.reservation_number
                JOIN passenger_ticket on booking.reservation_number = passenger_ticket.booking
                WHERE flightnumber = flight.flight_number);
END //


CREATE FUNCTION `calculateFreeSeats`(`flightnumber` INT) RETURNS INT
BEGIN
    /* There is 40 places on a plane. The number of free seats is therefor 40 - the booked ones. */
    RETURN 40 - calculateBookedSeats(flightnumber);
END //


CREATE FUNCTION `calculatePrice`(`flightnumber` INT) RETURNS DOUBLE
BEGIN
    DECLARE route_price DOUBLE;
    DECLARE profit_factor DOUBLE;
    DECLARE weekday_factor DOUBLE;

    SELECT r.price INTO route_price FROM flight
           JOIN weekly_schedule ws ON flight.weekly_flight = ws.id 
           JOIN route r ON (r.arrival = ws.arrival AND r.departure = ws.departure AND r.year = ws.route_year)
           WHERE flight.flight_number = flightnumber;

    SELECT w.pricing_factor, year.profit_factor INTO weekday_factor, profit_factor FROM flight 
        JOIN weekly_schedule ws ON flight.weekly_flight = ws.id 
        JOIN weekday w ON w.name = ws.weekday 
        JOIN year ON w.year = year.year
        WHERE flight.flight_number = flightnumber;

    RETURN ROUND(route_price * profit_factor * weekday_factor * (calculateBookedSeats(flightnumber)+1)/40, 13);
END //


/* A trigger that genereates a ticket number when you insert a new passenger into a booking */ 
CREATE TRIGGER `unique_ticket_number` BEFORE INSERT ON `passenger_ticket` FOR EACH ROW
BEGIN
    SET NEW.ticket_no = floor( 256203221 + (RAND() * 256203221));
END //


CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30), IN year INT, IN week INT, IN day VARCHAR(10), IN time TIME, IN number_of_passengers INT, OUT reservation_number INT)
BEGIN
    DECLARE flight_number INT;
    
    /* Get the flight that corresponds to the passed in parameters */
    SELECT flight.flight_number INTO flight_number FROM weekly_schedule w
        JOIN flight ON flight.weekly_flight = w.id
        WHERE w.departure = departure_airport_code 
            AND w.arrival = arrival_airport_code 
            AND w.year = year 
            AND w.weekday = day 
            AND w.departure_time = time 
            AND flight.week = week
        LIMIT 1;
    
    /* The flight must exist */
    IF flight_number is NULL THEN
    	SIGNAL SQLSTATE '42000' SET MESSAGE_TEXT = 'There exist no flightor the given route, date and time.';
    END IF;

    /* There must be enough free seats available */
    IF calculateFreeSeats(flight_number) < number_of_passengers THEN
    	SIGNAL SQLSTATE '42001' SET MESSAGE_TEXT = 'There are not enough seats available on the chosen flight.';
    END IF;

    INSERT INTO reservation (num_seats_reserved, flight) VALUES (number_of_passengers, flight_number);
    set reservation_number = LAST_INSERT_ID();
END //


CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT, IN name VARCHAR(30))
BEGIN
    DECLARE passenger INT;

    /* Check so that the reservation exists. This procedure call will give an error otherwise */
    IF (NOT EXISTS(SELECT reservation_number FROM reservation WHERE reservation_number = reservation_nr)) THEN
        SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The given reservation number does not exist.';
    END IF;

    SELECT p.passport_number INTO passenger FROM passenger p WHERE p.passport_number = passport_number;

    IF passenger is NULL THEN
        INSERT INTO passenger VALUES(passport_number, name);
    END IF;

    IF (EXISTS(SELECT * FROM booking WHERE reservation_number=reservation_nr)) THEN
        SIGNAL SQLSTATE '42005' SET MESSAGE_TEXT = 'The booking has already been payed and no further passengers can be added.';
    END IF;

    INSERT INTO reserved_on VALUES(passport_number, reservation_nr);
END //


CREATE PROCEDURE addContact(IN reservation_nr INT, IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
    DECLARE passenger INT;

    /* Check so that the reservation exists. This procedure call will give an error otherwise */
    IF (NOT EXISTS(SELECT reservation_number FROM reservation WHERE reservation_number = reservation_nr)) THEN
        SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The given reservation number does not exist.';
    END IF;

    SELECT ro.passenger INTO passenger FROM reserved_on ro WHERE ro.passenger = passport_number AND ro.reservation = reservation_nr;
    
    /* The contact must be a passenger */
    IF passenger is NULL THEN
        SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The person is not a passenger of the reservation.';
    END IF;

    /* The passenger as a contact */
    INSERT INTO contact VALUES(passenger, email, phone)
        ON DUPLICATE KEY UPDATE contact.email=email, contact.phone_number=phone;

    INSERT INTO contact_responsible VALUES(passport_number, reservation_nr);
END //


/* Procedure that pays for a reservation */
CREATE PROCEDURE addPayment(IN reservation_nr INT, IN cardholder_name VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
    DECLARE flight_number INT;
    DECLARE res_count INT;

    /* Check so that the reservation exists. This procedure call will give an error otherwise */
    IF (NOT EXISTS(SELECT reservation_number FROM reservation res WHERE reservation_number = reservation_nr)) THEN
        SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The given reservation number does not exist.';
    END IF;

    /* Get the flight number and number of seats for the reservation. */
    SELECT flight INTO flight_number FROM reservation res WHERE reservation_number=reservation_nr;
    SELECT COUNT(*) INTO res_count FROM reservation res JOIN reserved_on ro ON reservation_number=ro.reservation
        WHERE reservation_number = reservation_nr;

    /* The reservation must have a contact for it to be payable */
    IF (NOT EXISTS(SELECT * FROM contact_responsible cr WHERE cr.reservation=reservation_nr)) THEN
        SIGNAL SQLSTATE '42004' SET MESSAGE_TEXT = 'The reservation has no contact yet.';
    END IF;

    /* Check so that there is enough reserved seats */
    IF calculateFreeSeats(flight_number) < res_count THEN
        DELETE FROM reservation WHERE reservation_number=reservation_nr;
        SIGNAL SQLSTATE '42003' SET MESSAGE_TEXT = 'There are not enough seats available on the flight anymore, deleting reservation.';
    END IF;

    SELECT sleep(2);

    /* Everything is OK. Insert the values */
    /*INSERT IGNORE INTO credit_card VALUES(credit_card_number, cardholder_name);*/
    INSERT INTO credit_card VALUES(credit_card_number, cardholder_name)
        ON DUPLICATE KEY UPDATE ccn=credit_card_number;

    
    INSERT INTO booking VALUES(reservation_nr, calculatePrice(flight_number), credit_card_number);
    INSERT INTO passenger_ticket (booking, passenger) 
        (SELECT reservation_nr, passport_number FROM reserved_on ro
            JOIN passenger p ON (p.passport_number = ro.passenger) 
        WHERE ro.reservation = reservation_nr);

END //

delimiter ;

CREATE VIEW allFlights AS 
    SELECT ad.city_name departure_city_name, aa.city_name destination_city_name, ws.departure_time departure_time,
    ws.weekday departure_day, flight.week departure_week, ws.year departure_year, 
    calculateFreeSeats(flight.flight_number) nr_of_free_seats, calculatePrice(flight.flight_number) current_price_per_seat
    FROM weekly_schedule ws 
        JOIN flight ON flight.weekly_flight = ws.id
        JOIN route r ON (r.departure = ws.departure AND r.arrival = ws.arrival AND r.year = ws.route_year)
        JOIN airport aa ON (aa.airport_code = r.arrival)
        JOIN airport ad ON (ad.airport_code = r.departure);


source q10f.sql