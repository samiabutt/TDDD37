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
    ON DELETE NO ACTION
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
  PRIMARY KEY `pk_dep_arr`(`departure`, `arrival`),
  CONSTRAINT `fk_route_airport`
    FOREIGN KEY (`departure`)
    REFERENCES `airport` (`airport_code`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_airport_airport`
    FOREIGN KEY (`arrival`)
    REFERENCES `airport` (`airport_code`)
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
  PRIMARY KEY `pk_id`(`id`),
  CONSTRAINT `fk_weekday_sched_weekday`
    FOREIGN KEY (`year`)
    REFERENCES `weekday` (`year`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_weekday_weekday`
    FOREIGN KEY (`weekday`)
    REFERENCES `weekday` (`name`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_weekday_1_route`
    FOREIGN KEY (`departure`)
    REFERENCES `route` (`departure`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_weekday_2_route`
    FOREIGN KEY (`arrival`)
    REFERENCES `route` (`arrival`)
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
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE `credit_card` (
	`ccn` BIGINT NOT NULL,
	`name` VARCHAR(30),
	PRIMARY KEY `pk_ccn`(`ccn`)
);

CREATE TABLE `reservation` (
  `reservation_number` INT NOT NULL,
  `num_seats_reserved` INT NOT NULL,
  `flight` INT NOT NULL,
  PRIMARY KEY `pk_reservation_number`(`reservation_number`),
  CONSTRAINT `fk_reservation_flight`
    FOREIGN KEY (`flight`)
    REFERENCES `flight` (`flight_number`)
    ON DELETE NO ACTION
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
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_booking_credit_card`
    FOREIGN KEY (`credit_card`)
    REFERENCES `credit_card` (`ccn`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE `contact_responsible` (
  `contact` INT NOT NULL,
  `reservation` INT NOT NULL,
  PRIMARY KEY `pk_contact_reservation`(`contact`, `reservation`),
  CONSTRAINT `fk_cr_contact`
    FOREIGN KEY (`contact`)
    REFERENCES `contact` (`passport_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_cr_reservation`
    FOREIGN KEY (`reservation`)
    REFERENCES `reservation` (`reservation_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE `passenger_ticket` (
  `passenger` INT NOT NULL,
  `booking` INT NOT NULL,
  `ticket_no` INT NOT NULL,
  PRIMARY KEY `pk_passenger_booking`(`passenger`, `booking`),
  CONSTRAINT `fk_pt_passenger`
    FOREIGN KEY (`passenger`)
    REFERENCES `passenger` (`passport_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pt_booking`
    FOREIGN KEY (`booking`)
    REFERENCES `booking` (`reservation_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE `reserved_on` (
  `passenger` INT NOT NULL,
  `reservation` INT NOT NULL,
  PRIMARY KEY `pk_passenger_reservation`(`passenger`, `reservation`),
  CONSTRAINT `fk_ro_passenger`
    FOREIGN KEY (`passenger`)
    REFERENCES `passenger` (`passport_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ro_reservation`
    FOREIGN KEY (`reservation`)
    REFERENCES `reservation` (`reservation_number`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);


delimiter //

CREATE PROCEDURE addYear (IN year INT, IN factor DOUBLE)
BEGIN
	INSERT INTO year VALUES(year, factor);
END //

CREATE PROCEDURE addDay(IN year INT, IN day VARCHAR(10), IN factor DOUBLE)
BEGIN
	INSERT INTO weekDay VALUES(day, year, factor);
END //

CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
	INSERT INTO airport (airport_code, airport_name, country) VALUES(airport_code, name, country);
END //

CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
	IN year INT, IN routeprice DOUBLE)
BEGIN
	INSERT INTO route VALUES(departure_airport_code, arrival_airport_code, routeprice);
END //


CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(30),
IN year INT, IN day VARCHAR(10), IN departure_time)
BEGIN
	INSERT INTO weekly_schedule (departure_time, year, weekday, departure, arrival) 
	VALUES(departure_time, year, day, departure_airport_code, arrival_airport_code);
	SET @last_id = LAST_INSERT_ID();
	DECLARE p1 INT DEFAULT 0;
	WHILE p1 < 52 DO
	    SET p1 = p1 + 1;
	    INSERT INTO flight (week, weekly_flight) 
		VALUES(p1, @last_id);
	END WHILE;
END //



#year i route?

delimiter ;