SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `passenger`;
DROP TABLE IF EXISTS `contact`;
DROP TABLE IF EXISTS `year`;
DROP TABLE IF EXISTS `weekday`;
DROP TABLE IF EXISTS `airport`;
DROP TABLE IF EXISTS `route`;
DROP TABLE IF EXISTS `weekly_schedule`;
DROP TABLE IF EXISTS `flight`;
DROP TABLE IF EXISTS `credit_card`;
DROP TABLE IF EXISTS `reservation`;
DROP TABLE IF EXISTS `booking`;
DROP TABLE IF EXISTS `contact_responsible`;
DROP TABLE IF EXISTS `passenger_ticket`;
DROP TABLE IF EXISTS `reserved_on`;

DROP PROCEDURE IF EXISTS `addYear`;
DROP PROCEDURE IF EXISTS `addDay`;
DROP PROCEDURE IF EXISTS `addDestination`;
DROP PROCEDURE IF EXISTS `addRoute`;
DROP PROCEDURE IF EXISTS `addFlight`;
DROP PROCEDURE IF EXISTS `addReservation`;
DROP PROCEDURE IF EXISTS `addPassenger`;
DROP PROCEDURE IF EXISTS `addContact`;

DROP FUNCTION IF EXISTS `calculateFreeSeats`;
DROP FUNCTION IF EXISTS `calculatePrice`;
DROP FUNCTION IF EXISTS `reservationExists`;
DROP FUNCTION IF EXISTS `calculateBookedSeats`;

SET FOREIGN_KEY_CHECKS=1;

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
	INSERT INTO airport (airport_code, airport_name, country) VALUES(airport_code, name, country);
END //

CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
	IN year INT, IN routeprice DOUBLE)
BEGIN
	INSERT INTO route (departure, arrival, price, year) VALUES(departure_airport_code, arrival_airport_code, routeprice, year);
END //


CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
IN year INT, IN day VARCHAR(10), IN departure_time TIME)
BEGIN
	INSERT INTO weekly_schedule (departure_time, year, weekday, departure, arrival, route_year) 
	VALUES(departure_time, year, day, departure_airport_code, arrival_airport_code, year);
	SET @last_id = LAST_INSERT_ID();
	SET @p1 = 0;
	WHILE @p1 < 52 DO
	    SET @p1 = @p1 + 1;
	    INSERT INTO flight (week, weekly_flight) 
		VALUES(@p1, @last_id);
	END WHILE;
END //

CREATE FUNCTION `calculateBookedSeats`(`flightnumber` INT) RETURNS INT
BEGIN
  RETURN (SELECT COUNT(*) FROM `flight` f 
    JOIN `reservation` r ON f.flight_number = r.flight 
    JOIN `booking` b ON b.reservation_number = r.reservation_number);
END //

CREATE FUNCTION `calculateFreeSeats`(`flightnumber` INT) RETURNS INT
BEGIN
  RETURN 40 - calculateBookedSeats(flightnumber);
END //

CREATE FUNCTION `calculatePrice`(`flightnumber` INT) RETURNS DOUBLE
BEGIN
  SET @route_price = (SELECT r.price FROM flight f
           JOIN weekly_schedule ws ON f.weekly_flight = ws.id 
           JOIN route r ON (r.arrival = ws.arrival AND r.departure = ws.departure AND r.year = ws.route_year)
           WHERE f.flight_number = flightnumber);
  SET @profit_factor = 1;
  SET @weekday_factor = 1;

  SELECT w.pricing_factor, y.profit_factor INTO @weekday_factor, @profit_factor FROM flight f 
    JOIN weekly_schedule ws ON f.weekly_flight = ws.id 
    JOIN weekday w ON w.name = ws.weekday 
    JOIN year y ON w.year = y.year
    WHERE f.flight_number = flightnumber;

  set @booked_factor = (SELECT calculateBookedSeats(flightnumber)+1)/40;
  RETURN (@route_price * @profit_factor * @weekday_factor * @booked_factor);
END //

CREATE TRIGGER `unique_ticket_number` AFTER INSERT ON `passenger_ticket` FOR EACH ROW
BEGIN
	UPDATE `passenger_ticket` pt
	  SET pt.ticket_no = floor( 256203221 + (RAND() * 256203221))
	  WHERE pt.passenger = NEW.passenger and pt.booking = NEW.booking;
END //

CREATE FUNCTION reservationExists(reservation_nr INT) RETURNS BOOLEAN
BEGIN
  SET @res = (SELECT reservation_number FROM reservation WHERE reservation_number = reservation_nr);

  IF @res is NULL THEN
    SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The given reservation number does not exist.';
  END IF;

  RETURN 1;
END //

CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30), IN year INT, IN week INT, IN day VARCHAR(10), IN time TIME, IN number_of_passengers INT, OUT reservation_number INT)
BEGIN
    SET @flight_number = (SELECT f.flight_number FROM weekly_schedule w
      JOIN flight f ON f.weekly_flight = w.id
      WHERE w.departure = departure_airport_code 
        AND w.arrival = arrival_airport_code 
        AND w.year = year 
        AND w.weekday = day 
        AND w.departure_time = time 
        AND f.week = week);

    IF @flight_number is NULL THEN
    	SIGNAL SQLSTATE '42000' SET MESSAGE_TEXT = 'There exist no flight for the given route, date and time.';
    END IF;

    IF calculateFreeSeats(@flight_number) < number_of_passengers THEN
    	SIGNAL SQLSTATE '42001' SET MESSAGE_TEXT = 'There are not enough seats available on the chosen flight.';
    END IF;

    INSERT INTO reservation (num_seats_reserved, flight) VALUES (number_of_passengers, @flight_number);
    set reservation_number = LAST_INSERT_ID();
END //

CREATE PROCEDURE addPassenger(IN reservation_nr INT, IN passport_number INT, IN name VARCHAR(30))
BEGIN
  set @tmp = reservationExists(reservation_nr);

  SET @passenger = (SELECT p.passport_number FROM passenger p WHERE p.passport_number = passport_number);

  IF @passenger is NULL THEN
    INSERT INTO passenger VALUES(passport_number, name);
  END IF;

  INSERT INTO reserved_on VALUES(passport_number, reservation_nr);
END //

/*addContact(reservation_nr, passport_number, email, phone);*/

CREATE PROCEDURE addContact(IN reservation_nr INT, IN passport_number INT, IN email VARCHAR(30), IN phone BIGINT)
BEGIN
  set @tmp = reservationExists(reservation_nr);

  SET @passenger = (SELECT ro.passenger FROM reserved_on ro WHERE ro.passenger = passport_number AND ro.reservation = reservation_nr);
  IF @passenger is NULL THEN
    SIGNAL SQLSTATE '42002' SET MESSAGE_TEXT = 'The person is not a passenger of the reservation.';
  END IF;

END //

delimiter ;
