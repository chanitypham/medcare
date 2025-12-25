DELIMITER $$

CREATE TRIGGER trg_check_doctor_patient_insert
BEFORE INSERT ON diagnosis
FOR EACH ROW
BEGIN
    IF NEW.doctor_id = NEW.patient_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'doctor_id and patient_id must be different';
    END IF;
END$$

CREATE TRIGGER trg_check_doctor_patient_update
BEFORE UPDATE ON diagnosis
FOR EACH ROW
BEGIN
    IF NEW.doctor_id = NEW.patient_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'doctor_id and patient_id must be different';
    END IF;
END$$

DELIMITER ;