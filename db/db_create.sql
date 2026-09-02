-- Core Schema
DROP DATABASE IF EXISTS MAW11_Looper_RGK;
CREATE DATABASE MAW11_Looper_RGK CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE MAW11_Looper_RGK;

-- FORM table
CREATE TABLE forms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NULL,
    status VARCHAR(30) NOT NULL
);

-- LABELS table
CREATE TABLE labels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    label_name VARCHAR(50) NULL,
    type VARCHAR(30) NOT NULL,
    form_id INT NOT NULL,
    CONSTRAINT fk_labels_form
        FOREIGN KEY (form_id) REFERENCES forms(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
