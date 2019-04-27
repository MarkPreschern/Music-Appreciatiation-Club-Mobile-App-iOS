-- -----------------------------------------------------
-- Schema music_appreciation_club
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `music_appreciation_club` DEFAULT CHARACTER SET utf8 ;
USE `music_appreciation_club` ;

-- -----------------------------------------------------
-- Table `music_appreciation_club`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `name_first` VARCHAR(100) NOT NULL,
  `name_last` VARCHAR(100) NOT NULL,
  `nuid` INT NOT NULL,
  `role` VARCHAR(100) NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`item` (
  `item_id` INT NOT NULL AUTO_INCREMENT,
  `is_album` TINYINT NOT NULL,
  `item_name` VARCHAR(255) NOT NULL,
  `item_artist` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`item_id`),
  UNIQUE INDEX `item_id_UNIQUE` (`item_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`favorite`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`favorite` (
  `favorite_id` INT NOT NULL AUTO_INCREMENT,
  `date_favorited` DATETIME NOT NULL,
  `user_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  PRIMARY KEY (`favorite_id`, `user_id`, `item_id`),
  UNIQUE INDEX `favor_UNIQUE` (`favorite_id` ASC) VISIBLE,
  INDEX `fk_favorite_user1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_favorite_item2_idx` (`item_id` ASC) VISIBLE,
  CONSTRAINT `fk_favorite_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_item2`
    FOREIGN KEY (`item_id`)
    REFERENCES `music_appreciation_club`.`item` (`item_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`favorite_weekly`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`favorite_weekly` (
  `favorite_weekly_id` INT NOT NULL AUTO_INCREMENT,
  `date_favorited` DATETIME NOT NULL,
  `user_id` INT NOT NULL,
  `item_id` INT NOT NULL,
  PRIMARY KEY (`favorite_weekly_id`, `user_id`, `item_id`),
  UNIQUE INDEX `favorite_weekly_id_UNIQUE` (`favorite_weekly_id` ASC) VISIBLE,
  INDEX `fk_favorite_weekly_user1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_favorite_weekly_item1_idx` (`item_id` ASC) VISIBLE,
  CONSTRAINT `fk_favorite_weekly_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_weekly_item1`
    FOREIGN KEY (`item_id`)
    REFERENCES `music_appreciation_club`.`item` (`item_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`vote`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`vote` (
  `vote_id` INT NOT NULL AUTO_INCREMENT,
  `up` TINYINT NOT NULL,
  `comment` VARCHAR(255) NULL,
  `user_id` INT NOT NULL,
  `favorite_id` INT NOT NULL,
  `favorite_weekly_id` INT NOT NULL,
  PRIMARY KEY (`vote_id`, `user_id`, `favorite_id`, `favorite_weekly_id`),
  INDEX `fk_vote_user1_idx` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `vote_id_UNIQUE` (`vote_id` ASC) VISIBLE,
  INDEX `fk_vote_favorite1_idx` (`favorite_id` ASC) VISIBLE,
  INDEX `fk_vote_favorite_weekly1_idx` (`favorite_weekly_id` ASC) VISIBLE,
  CONSTRAINT `fk_vote_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_vote_favorite1`
    FOREIGN KEY (`favorite_id`)
    REFERENCES `music_appreciation_club`.`favorite` (`favorite_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_vote_favorite_weekly1`
    FOREIGN KEY (`favorite_weekly_id`)
    REFERENCES `music_appreciation_club`.`favorite_weekly` (`favorite_weekly_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;