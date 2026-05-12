-- ============================================================
-- Лабораторная работа: Графовые базы данных в MS SQL Server
-- Вариант 65: Архитектура города — Памятники, Улицы, Архитекторы
-- ============================================================

USE master;
GO

IF DB_ID('CityArchitectureGraph') IS NOT NULL
BEGIN
    ALTER DATABASE CityArchitectureGraph SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CityArchitectureGraph;
END
GO

CREATE DATABASE CityArchitectureGraph
    COLLATE Cyrillic_General_CI_AS;
GO

USE CityArchitectureGraph;
GO

-- ============================================================
-- 1. ТАБЛИЦЫ УЗЛОВ (NODE TABLES)
-- ============================================================

-- Узел: Архитекторы
CREATE TABLE Architects (
    ArchitectID    INT           NOT NULL,
    FullName       NVARCHAR(100) NOT NULL,
    BirthYear      INT,
    DeathYear      INT,
    Nationality    NVARCHAR(50),
    Specialization NVARCHAR(100)
) AS NODE;
GO

-- Узел: Памятники
CREATE TABLE Monuments (
    MonumentID   INT            NOT NULL,
    MonumentName NVARCHAR(150)  NOT NULL,
    YearBuilt    INT,
    Style        NVARCHAR(100),
    HeightM      DECIMAL(6,2),
    Description  NVARCHAR(500)
) AS NODE;
GO

-- Узел: Улицы
CREATE TABLE Streets (
    StreetID     INT            NOT NULL,
    StreetName   NVARCHAR(150)  NOT NULL,
    LengthKm     DECIMAL(6,3),
    District     NVARCHAR(100),
    WidthM       DECIMAL(5,1),
    FoundedYear  INT
) AS NODE;
GO

-- ============================================================
-- 2. ТАБЛИЦЫ РЁБЕР (EDGE TABLES) С CONNECTION CONSTRAINTS
-- ============================================================

-- Ребро: Памятник РАСПОЛОЖЕН НА улице
CREATE TABLE Located_On (
    DatePlaced        DATE,
    SectorDescription NVARCHAR(200),
    IsMainEntrance    BIT DEFAULT 0
) AS EDGE;
GO

ALTER TABLE Located_On
    ADD CONSTRAINT EC_LocatedOn
    CONNECTION (Monuments TO Streets);
GO

-- Ребро: Объект (памятник или улица) СПРОЕКТИРОВАН архитектором
CREATE TABLE Designed_By (
    DesignYear    INT,
    Role          NVARCHAR(100),
    AwardReceived NVARCHAR(200)
) AS EDGE;
GO

ALTER TABLE Designed_By
    ADD CONSTRAINT EC_DesignedBy
    CONNECTION (Monuments TO Architects, Streets TO Architects);
GO

-- Ребро: Архитектор СОТРУДНИЧАЛ С другим архитектором
CREATE TABLE Collaborated_With (
    ProjectName       NVARCHAR(200),
    CollaborationYear INT,
    CollabType        NVARCHAR(100)
) AS EDGE;
GO

ALTER TABLE Collaborated_With
    ADD CONSTRAINT EC_CollaboratedWith
    CONNECTION (Architects TO Architects);
GO

-- Ребро: Улица СОЕДИНЯЕТСЯ С другой улицей
CREATE TABLE Connects_To (
    JunctionType NVARCHAR(100),
    TrafficLevel NVARCHAR(50),
    BuiltYear    INT
) AS EDGE;
GO

ALTER TABLE Connects_To
    ADD CONSTRAINT EC_ConnectsTo
    CONNECTION (Streets TO Streets);
GO

-- ============================================================
-- 3. ЗАПОЛНЕНИЕ ТАБЛИЦ УЗЛОВ (не менее 10 строк каждая)
-- ============================================================

-- Архитекторы (12 записей)
INSERT INTO Architects (ArchitectID, FullName, BirthYear, DeathYear, Nationality, Specialization)
VALUES
(1,  N'Матвей Казаков',     1738, 1812, N'Российский', N'Классицизм'),
(2,  N'Василий Баженов',    1737, 1799, N'Российский', N'Классицизм, Неоготика'),
(3,  N'Осип Бове',          1784, 1834, N'Российский', N'Ампир'),
(4,  N'Константин Тон',     1794, 1881, N'Российский', N'Русско-Византийский'),
(5,  N'Алексей Щусев',      1873, 1949, N'Советский',  N'Модерн, Конструктивизм'),
(6,  N'Борис Иофан',        1891, 1976, N'Советский',  N'Сталинский ампир'),
(7,  N'Лев Руднев',         1885, 1956, N'Советский',  N'Сталинский ампир'),
(8,  N'Михаил Посохин',     1910, 1989, N'Советский',  N'Советский модернизм'),
(9,  N'Иван Жолтовский',    1867, 1959, N'Советский',  N'Неоклассицизм'),
(10, N'Владимир Шухов',     1853, 1939, N'Российский', N'Конструктивизм, Инженерия'),
(11, N'Роман Клейн',        1858, 1924, N'Российский', N'Эклектика, Неоклассицизм'),
(12, N'Фёдор Шехтель',      1859, 1926, N'Российский', N'Модерн');
GO

-- Памятники (12 записей)
INSERT INTO Monuments (MonumentID, MonumentName, YearBuilt, Style, HeightM, Description)
VALUES
(1,  N'Храм Христа Спасителя',          1883, N'Русско-Византийский',  103.0,  N'Крупнейший православный храм России'),
(2,  N'Большой театр',                   1825, N'Ампир',                 45.0,  N'Главный театр страны'),
(3,  N'Дом Пашкова',                     1786, N'Классицизм',            22.5,  N'Один из красивейших особняков Москвы'),
(4,  N'Шуховская башня',                 1922, N'Конструктивизм',       160.0,  N'Стальная гиперболоидная башня'),
(5,  N'Главное здание МГУ',              1953, N'Сталинский ампир',     182.0,  N'Высотное здание Московского университета'),
(6,  N'Гостиница Украина',               1957, N'Сталинский ампир',     206.0,  N'Одна из семи сталинских высоток'),
(7,  N'Мавзолей Ленина',                 1930, N'Конструктивизм',        12.0,  N'Гранитный мавзолей на Красной площади'),
(8,  N'Музей изобразительных искусств',  1912, N'Неоклассицизм',         20.0,  N'Государственный музей им. Пушкина'),
(9,  N'Дворец Советов (проект)',          1934, N'Сталинский ампир',     415.0,  N'Неосуществлённый грандиозный проект'),
(10, N'Триумфальная арка',               1834, N'Ампир',                  28.0,  N'В честь победы в Отечественной войне 1812 г.'),
(11, N'Петровский путевой дворец',       1782, N'Неоготика',              18.0,  N'Дворец для отдыха царей'),
(12, N'Здание Моссовета',                1782, N'Классицизм',             20.0,  N'Бывший дом генерал-губернатора');
GO

-- Улицы (12 записей)
INSERT INTO Streets (StreetID, StreetName, LengthKm, District, WidthM, FoundedYear)
VALUES
(1,  N'Тверская улица',       6.000, N'Центральный',         60.0, 1156),
(2,  N'Арбат',                1.200, N'Центральный',         15.0, 1493),
(3,  N'Воздвиженка',          0.800, N'Центральный',         25.0, 1565),
(4,  N'Моховая улица',        0.500, N'Центральный',         30.0, 1820),
(5,  N'Красная площадь',      0.700, N'Центральный',         70.0, 1493),
(6,  N'Ленинский проспект',  16.000, N'Юго-Западный',        80.0, 1957),
(7,  N'Новый Арбат',          3.000, N'Центральный',         60.0, 1963),
(8,  N'Проспект Мира',       19.000, N'Северо-Восточный',    50.0, 1957),
(9,  N'Садовое кольцо',      15.000, N'Центральный',         60.0, 1816),
(10, N'Петровка',             2.000, N'Центральный',         25.0, 1493),
(11, N'Кутузовский проспект',14.000, N'Западный',            70.0, 1957),
(12, N'Охотный ряд',          0.400, N'Центральный',         40.0, 1493);
GO

-- ============================================================
-- 4. ЗАПОЛНЕНИЕ ТАБЛИЦ РЁБЕР
-- ============================================================

-- ---- Located_On: Памятник расположен на улице ----

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1883-12-26', N'Центральная часть, берег реки Москвы', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 1  AND s.StreetID = 4;   -- Храм ХС → Моховая

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1825-01-14', N'Театральная площадь', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 2  AND s.StreetID = 10;  -- Большой театр → Петровка

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1786-01-01', N'Холм у Кремлёвской стены', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 3  AND s.StreetID = 3;   -- Дом Пашкова → Воздвиженка

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1922-03-19', N'Шаболовка (примыкает к Садовому кольцу)', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 4  AND s.StreetID = 9;   -- Шуховская башня → Садовое кольцо

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1953-09-01', N'Воробьёвы горы, начало Ленинского проспекта', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 5  AND s.StreetID = 6;   -- ГЗ МГУ → Ленинский проспект

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1957-01-01', N'Набережная у Кутузовского проспекта', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 6  AND s.StreetID = 11;  -- Гостиница Украина → Кутузовский

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1930-10-27', N'Красная площадь, у Кремлёвской стены', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 7  AND s.StreetID = 5;   -- Мавзолей → Красная площадь

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1912-06-03', N'Волхонка, 12 (угол Моховой)', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 8  AND s.StreetID = 4;   -- ГМИИ → Моховая

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1834-09-20', N'Кутузовский проспект, площадь Победы', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 10 AND s.StreetID = 11;  -- Триумфальная арка → Кутузовский

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1782-01-01', N'Ленинградский проспект (Тверская)', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 11 AND s.StreetID = 1;   -- Петровский дворец → Тверская

INSERT INTO Located_On ($from_id, $to_id, DatePlaced, SectorDescription, IsMainEntrance)
SELECT m.$node_id, s.$node_id, '1782-01-01', N'Тверская улица, дом 13', 1
FROM Monuments m, Streets s WHERE m.MonumentID = 12 AND s.StreetID = 1;   -- Моссовет → Тверская
GO

-- ---- Designed_By: Объект спроектирован архитектором ----

-- Памятники → Архитекторы
INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1839, N'Главный архитектор', N'Орден Св. Владимира'
FROM Monuments m, Architects a WHERE m.MonumentID = 1  AND a.ArchitectID = 4;  -- Храм ХС → Тон

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1821, N'Главный архитектор', N'Золотая медаль АХ'
FROM Monuments m, Architects a WHERE m.MonumentID = 2  AND a.ArchitectID = 3;  -- Большой театр → Бове

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1784, N'Главный архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 3  AND a.ArchitectID = 2;  -- Дом Пашкова → Баженов

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1919, N'Главный инженер-архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 4  AND a.ArchitectID = 10; -- Шуховская башня → Шухов

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1948, N'Главный архитектор', N'Сталинская премия'
FROM Monuments m, Architects a WHERE m.MonumentID = 5  AND a.ArchitectID = 7;  -- ГЗ МГУ → Руднев

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1953, N'Главный архитектор', N'Сталинская премия'
FROM Monuments m, Architects a WHERE m.MonumentID = 6  AND a.ArchitectID = 6;  -- Гостиница Украина → Иофан

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1924, N'Главный архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 7  AND a.ArchitectID = 5;  -- Мавзолей → Щусев

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1898, N'Главный архитектор', N'Золотая медаль АХ'
FROM Monuments m, Architects a WHERE m.MonumentID = 8  AND a.ArchitectID = 11; -- ГМИИ → Клейн

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1931, N'Главный архитектор', N'Гран-при выставки'
FROM Monuments m, Architects a WHERE m.MonumentID = 9  AND a.ArchitectID = 6;  -- Дворец Советов → Иофан

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1827, N'Главный архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 10 AND a.ArchitectID = 3;  -- Триумфальная арка → Бове

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1776, N'Главный архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 11 AND a.ArchitectID = 2;  -- Петровский дворец → Баженов

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT m.$node_id, a.$node_id, 1780, N'Главный архитектор', N'Нет'
FROM Monuments m, Architects a WHERE m.MonumentID = 12 AND a.ArchitectID = 1;  -- Моссовет → Казаков

-- Улицы → Архитекторы
INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT s.$node_id, a.$node_id, 1824, N'Автор планировки и реконструкции', N'Золотая медаль'
FROM Streets s, Architects a WHERE s.StreetID = 1  AND a.ArchitectID = 3;  -- Тверская → Бове

INSERT INTO Designed_By ($from_id, $to_id, DesignYear, Role, AwardReceived)
SELECT s.$node_id, a.$node_id, 1958, N'Автор планировки', N'Ленинская премия'
FROM Streets s, Architects a WHERE s.StreetID = 7  AND a.ArchitectID = 8;  -- Новый Арбат → Посохин
GO

-- ---- Collaborated_With: Архитектор сотрудничал с архитектором ----

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Реконструкция Москвы после пожара 1812', 1813, N'Совместное проектирование'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 3 AND a2.ArchitectID = 1;  -- Бове → Казаков

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Дворец Советов', 1931, N'Совместное проектирование'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 6 AND a2.ArchitectID = 9;  -- Иофан → Жолтовский

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Программа сталинских высоток', 1948, N'Совместная концепция'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 6 AND a2.ArchitectID = 7;  -- Иофан → Руднев

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Программа сталинских высоток', 1948, N'Совместная концепция'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 7 AND a2.ArchitectID = 8;  -- Руднев → Посохин

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Казанский вокзал', 1910, N'Совместный авторский надзор'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 5 AND a2.ArchitectID = 9;  -- Щусев → Жолтовский

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Планировка центральных кварталов Москвы', 1787, N'Консультация'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 1 AND a2.ArchitectID = 2;  -- Казаков → Баженов

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Архитектурный конкурс особняков', 1900, N'Конкурс'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 11 AND a2.ArchitectID = 12; -- Клейн → Шехтель

INSERT INTO Collaborated_With ($from_id, $to_id, ProjectName, CollaborationYear, CollabType)
SELECT a1.$node_id, a2.$node_id,
       N'Генеральный план реконструкции Москвы', 1935, N'Совместный план'
FROM Architects a1, Architects a2 WHERE a1.ArchitectID = 5 AND a2.ArchitectID = 6;  -- Щусев → Иофан
GO

-- ---- Connects_To: Улица соединяется с улицей ----

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Пересечение', N'Высокий', 1820
FROM Streets s1, Streets s2 WHERE s1.StreetID = 1  AND s2.StreetID = 9;   -- Тверская → Садовое кольцо

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Пересечение', N'Высокий', 1820
FROM Streets s1, Streets s2 WHERE s1.StreetID = 9  AND s2.StreetID = 11;  -- Садовое кольцо → Кутузовский

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Примыкание', N'Средний', 1493
FROM Streets s1, Streets s2 WHERE s1.StreetID = 2  AND s2.StreetID = 7;   -- Арбат → Новый Арбат

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Примыкание', N'Высокий', 1963
FROM Streets s1, Streets s2 WHERE s1.StreetID = 7  AND s2.StreetID = 11;  -- Новый Арбат → Кутузовский

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Пересечение', N'Высокий', 1493
FROM Streets s1, Streets s2 WHERE s1.StreetID = 1  AND s2.StreetID = 12;  -- Тверская → Охотный ряд

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Примыкание', N'Средний', 1493
FROM Streets s1, Streets s2 WHERE s1.StreetID = 12 AND s2.StreetID = 4;   -- Охотный ряд → Моховая

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Примыкание', N'Низкий', 1565
FROM Streets s1, Streets s2 WHERE s1.StreetID = 4  AND s2.StreetID = 3;   -- Моховая → Воздвиженка

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Примыкание', N'Низкий', 1565
FROM Streets s1, Streets s2 WHERE s1.StreetID = 3  AND s2.StreetID = 2;   -- Воздвиженка → Арбат

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Пересечение', N'Высокий', 1957
FROM Streets s1, Streets s2 WHERE s1.StreetID = 6  AND s2.StreetID = 9;   -- Ленинский → Садовое кольцо

INSERT INTO Connects_To ($from_id, $to_id, JunctionType, TrafficLevel, BuiltYear)
SELECT s1.$node_id, s2.$node_id, N'Пересечение', N'Высокий', 1957
FROM Streets s1, Streets s2 WHERE s1.StreetID = 8  AND s2.StreetID = 9;   -- Проспект Мира → Садовое кольцо
GO

-- ============================================================
-- 5. ЗАПРОСЫ С ФУНКЦИЕЙ MATCH (не менее 5)
-- ============================================================

-- Запрос М-1: Все памятники и архитекторы, которые их спроектировали
PRINT N'=== М-1: Памятники и их архитекторы ===';
SELECT
    m.MonumentName,
    m.Style,
    a.FullName    AS Architect,
    d.DesignYear,
    d.Role,
    d.AwardReceived
FROM Monuments m, Designed_By d, Architects a
WHERE MATCH(m-(d)->a)
ORDER BY m.MonumentName;
GO

-- Запрос М-2: Все памятники и улицы, на которых они расположены
PRINT N'=== М-2: Памятники и улицы их расположения ===';
SELECT
    m.MonumentName,
    m.YearBuilt,
    s.StreetName,
    s.District,
    lo.DatePlaced,
    lo.SectorDescription
FROM Monuments m, Located_On lo, Streets s
WHERE MATCH(m-(lo)->s)
ORDER BY s.StreetName, m.MonumentName;
GO

-- Запрос М-3 (цепочка 3 узла): Памятники → Улица → Смежная улица
-- Найти, с какими улицами соединены улицы, на которых стоят памятники
PRINT N'=== М-3: Памятник → улица → смежная улица (цепочка 3 узла) ===';
SELECT
    m.MonumentName,
    s1.StreetName  AS DirectStreet,
    s2.StreetName  AS ConnectedStreet,
    ct.JunctionType,
    ct.TrafficLevel
FROM Monuments m, Located_On lo, Streets s1, Connects_To ct, Streets s2
WHERE MATCH(m-(lo)->s1-(ct)->s2)
ORDER BY m.MonumentName, s2.StreetName;
GO

-- Запрос М-4 (цепочка 3 узла): Памятники стиля "Сталинский ампир" → Архитектор → Соавтор
-- Найти соавторов архитекторов сталинских памятников
PRINT N'=== М-4: Памятник (Сталинский ампир) → архитектор → его соавтор (цепочка 3 узла) ===';
SELECT
    m.MonumentName,
    a1.FullName    AS DirectArchitect,
    a2.FullName    AS Collaborator,
    c.ProjectName,
    c.CollaborationYear
FROM Monuments m, Designed_By d, Architects a1, Collaborated_With c, Architects a2
WHERE MATCH(m-(d)->a1-(c)->a2)
  AND m.Style = N'Сталинский ампир'
ORDER BY m.MonumentName, a2.FullName;
GO

-- Запрос М-5 (цепочка 4 узла): Памятник → Улица → Смежная улица → Архитектор смежной улицы
-- Найти архитекторов улиц, смежных с улицами, на которых расположены памятники
PRINT N'=== М-5: Памятник → улица → смежная улица → архитектор смежной улицы (цепочка 4 узла) ===';
SELECT
    m.MonumentName,
    s1.StreetName  AS MonumentStreet,
    s2.StreetName  AS AdjacentStreet,
    a.FullName     AS AdjacentStreetArchitect,
    db.DesignYear
FROM Monuments m, Located_On lo, Streets s1, Connects_To ct, Streets s2, Designed_By db, Architects a
WHERE MATCH(m-(lo)->s1-(ct)->s2-(db)->a)
ORDER BY m.MonumentName, s2.StreetName;
GO

-- Запрос М-6: Пары сотрудничавших архитекторов и все памятники первого из пары
PRINT N'=== М-6: Соавторы архитекторов и памятники первого автора ===';
SELECT
    a1.FullName     AS Architect,
    a2.FullName     AS Collaborator,
    c.ProjectName,
    m.MonumentName  AS ArchitectMonument,
    m.YearBuilt
FROM Architects a1, Collaborated_With c, Architects a2,
     Designed_By d, Monuments m
WHERE MATCH(a1-(c)->a2 AND m-(d)->a1)
ORDER BY a1.FullName, m.MonumentName;
GO

-- ============================================================
-- 6. ЗАПРОСЫ С ФУНКЦИЕЙ SHORTEST_PATH (не менее 2)
-- ============================================================

-- Запрос SP-1 (шаблон "+"): Кратчайший путь от Тверской до всех достижимых улиц
-- Минимум 1 шаг, неограниченная глубина; вывод имён промежуточных узлов
PRINT N'=== SP-1: Кратчайший путь от Тверской до всех улиц (шаблон +) ===';
SELECT
    src.StreetName                                                        AS StartStreet,
    LAST_VALUE(dst.StreetName) WITHIN GROUP (GRAPH PATH)                  AS EndStreet,
    COUNT(ct.$edge_id)         WITHIN GROUP (GRAPH PATH)                  AS HopCount,
    STRING_AGG(dst.StreetName, N' -> ') WITHIN GROUP (GRAPH PATH)         AS PathViaStreets
FROM
    Streets          AS src,
    Connects_To FOR PATH AS ct,
    Streets     FOR PATH AS dst
WHERE MATCH(SHORTEST_PATH(src-(ct->dst)+))
  AND src.StreetID = 1   -- Начальная точка: Тверская улица
ORDER BY HopCount, EndStreet;
GO

-- Запрос SP-2 (шаблон "{1,n}"): Цепочки сотрудничества от Щусева длиной 1–4 шага
-- Найти всех архитекторов, достижимых через цепочку соавторства из 1–4 связей
PRINT N'=== SP-2: Кратчайший путь через сотрудничество от Щусева (шаблон {1,4}) ===';
SELECT
    src.FullName                                                           AS StartArchitect,
    LAST_VALUE(dst.FullName) WITHIN GROUP (GRAPH PATH)                    AS ReachedArchitect,
    COUNT(c.$edge_id)        WITHIN GROUP (GRAPH PATH)                    AS CollabSteps,
    STRING_AGG(dst.FullName, N' -> ') WITHIN GROUP (GRAPH PATH)           AS CollaborationPath
FROM
    Architects           AS src,
    Collaborated_With FOR PATH AS c,
    Architects        FOR PATH AS dst
WHERE MATCH(SHORTEST_PATH(src-(c->dst){1,4}))
  AND src.ArchitectID = 5   -- Начальная точка: Алексей Щусев
ORDER BY CollabSteps, ReachedArchitect;
GO
