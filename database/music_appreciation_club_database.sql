-- -----------------------------------------------------
-- Schema music_appreciation_club
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `music_appreciation_club` DEFAULT CHARACTER SET utf8 ;
-- -----------------------------------------------------
-- Schema music_appreciation_club
-- -----------------------------------------------------
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
-- Table `music_appreciation_club`.`album`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`album` (
  `album_id` INT NOT NULL AUTO_INCREMENT,
  `album_name` VARCHAR(100) NOT NULL,
  `album_artist` VARCHAR(100) NOT NULL,
  `album_image` BLOB NULL,
  PRIMARY KEY (`album_id`),
  UNIQUE INDEX `album_id_UNIQUE` (`album_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`song`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`song` (
  `song_id` INT NOT NULL AUTO_INCREMENT,
  `song_name` VARCHAR(100) NOT NULL,
  `song_artist` VARCHAR(100) NOT NULL,
  `song_image` BLOB NULL,
  `album_id` INT NULL,
  PRIMARY KEY (`song_id`),
  UNIQUE INDEX `song_id_UNIQUE` (`song_id` ASC) VISIBLE,
  INDEX `fk_song_id_album_id1_idx` (`album_id` ASC) VISIBLE,
  CONSTRAINT `fk_song_id_album_id1`
    FOREIGN KEY (`album_id`)
    REFERENCES `music_appreciation_club`.`album` (`album_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`favorite`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`favorite` (
  `favorite_id` INT NOT NULL AUTO_INCREMENT,
  `date_favorited` DATETIME NOT NULL,
  `user_id` INT NOT NULL,
  `song_id` INT NULL,
  `album_id` INT NULL,
  PRIMARY KEY (`favorite_id`),
  UNIQUE INDEX `favor_UNIQUE` (`favorite_id` ASC) VISIBLE,
  INDEX `fk_favorite_id_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_favorite_id_song_id1_idx` (`song_id` ASC) VISIBLE,
  INDEX `fk_favorite_id_album_id1_idx` (`album_id` ASC) VISIBLE,
  CONSTRAINT `fk_favorite_id_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_id_song_id1`
    FOREIGN KEY (`song_id`)
    REFERENCES `music_appreciation_club`.`song` (`song_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_id_album_id1`
    FOREIGN KEY (`album_id`)
    REFERENCES `music_appreciation_club`.`album` (`album_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`weekly_favorites`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`weekly_favorites` (
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `music_appreciation_club`.`favorite_weekly`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `music_appreciation_club`.`favorite_weekly` (
  `favorite_weekly_id` INT NOT NULL AUTO_INCREMENT,
  `date_favorited` DATETIME NOT NULL,
  `user_id` INT NOT NULL,
  `song_id` INT NULL,
  `album_id` INT NULL,
  PRIMARY KEY (`favorite_weekly_id`),
  UNIQUE INDEX `favorite_weekly_id_UNIQUE` (`favorite_weekly_id` ASC) VISIBLE,
  INDEX `fk_favorite_weekly_id_user1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_favorite_weekly_id_song_id1_idx` (`song_id` ASC) VISIBLE,
  INDEX `fk_favorite_weekly_id_album_id1_idx` (`album_id` ASC) VISIBLE,
  CONSTRAINT `fk_favorite_weekly_id_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_weekly_id_song_id1`
    FOREIGN KEY (`song_id`)
    REFERENCES `music_appreciation_club`.`song` (`song_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_favorite_weekly_id_album_id1`
    FOREIGN KEY (`album_id`)
    REFERENCES `music_appreciation_club`.`album` (`album_id`)
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
  INDEX `fk_vote_favorite_id1_idx` (`favorite_id` ASC) VISIBLE,
  INDEX `fk_vote_favorite_weekly_id1_idx` (`favorite_weekly_id` ASC) VISIBLE,
  CONSTRAINT `fk_vote_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `music_appreciation_club`.`user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_vote_favorite_id1`
    FOREIGN KEY (`favorite_id`)
    REFERENCES `music_appreciation_club`.`favorite` (`favorite_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_vote_favorite_weekly_id1`
    FOREIGN KEY (`favorite_weekly_id`)
    REFERENCES `music_appreciation_club`.`favorite_weekly` (`favorite_weekly_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;