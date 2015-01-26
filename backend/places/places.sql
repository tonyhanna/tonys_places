-- phpMyAdmin SQL Dump
-- version 2.11.11.1
-- http://www.phpmyadmin.net
--
-- Host: mysql50-67.wc2:3306
-- Generation Time: Jun 21, 2011 at 12:52 AM
-- Server version: 5.0.77
-- PHP Version: 5.2.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `535794_places`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_devices`
--

CREATE TABLE IF NOT EXISTS `admin_devices` (
  `udid` varchar(40) NOT NULL,
  `name` varchar(50) NOT NULL,
  `access` tinyint(4) NOT NULL,
  PRIMARY KEY  (`udid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_devices`
--

INSERT INTO `admin_devices` (`udid`, `name`, `access`) VALUES
('515a41f116b5274d7e1ba0092d8a9d8eb6bc8c9c', 'Tony iPhone', 1),
('e884b9a271b73cc2eed3a4b93b20811b52c0b130', 'Senja iPhone', 1);

-- --------------------------------------------------------

--
-- Table structure for table `places`
--

CREATE TABLE IF NOT EXISTS `places` (
  `id` varchar(50) NOT NULL,
  `name` varchar(60) NOT NULL,
  `category` varchar(60) NOT NULL,
  `description` varchar(255) default NULL,
  `lat` float(10,6) NOT NULL,
  `lng` float(10,6) NOT NULL,
  `verified` tinyint(4) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `twitter` varchar(50) NOT NULL,
  `address` varchar(200) NOT NULL,
  `crossStreet` varchar(200) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `postalCode` varchar(50) NOT NULL,
  `country` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;

--
-- Dumping data for table `places`
--

INSERT INTO `places` (`id`, `name`, `category`, `description`, `lat`, `lng`, `verified`, `phone`, `twitter`, `address`, `crossStreet`, `city`, `state`, `postalCode`, `country`) VALUES
('4bee3153e24d20a186b27214', 'Food court griya', 'Fast Food Restaurant', '', -6.893100, 107.635002, 0, '', '', 'Jl. Pahlawan', '', 'Bandung', 'Jawa Barat', '', ''),
('4c1879974ff90f47737e0e49', 'Kantin pinus', 'Asian Restaurant', '', -6.871980, 107.616997, 0, '', '', '', '', '', '', '', ''),
('4be143c0ea6e20a178f79267', 'Waroeng Steak ', 'Steakhouse', '', -6.906660, 107.621002, 0, '', '', '', '', '', '', '', ''),
('4c6d48811585ef3b5e1f0a9e', 'Hiroz Food Corner', '', '', -6.898740, 107.634003, 0, '', '', '', '', '', '', '', ''),
('4bfa81b88d30d13a8ea80318', 'ATMOSPHERE Dine ', 'Eastern European Restaurant', '', -6.926310, 107.612999, 0, '', '', '', '', '', '', '', ''),
('4c19e06d838020a16160e661', 'Sultan''s House', '', '', -6.930940, 107.622002, 0, '', '', '', '', '', '', '', ''),
('4c12f62982a3c9b6a4c7faf8', 'Food Court Universitas Widyatama', 'Arcade, Food Court, Coffee Shop', '', -6.900120, 107.642998, 0, '', '', '', '', '', '', '', ''),
('4bd35dbb046076b059ea7571', 'Universitas Widyatama', 'College Library, Asian Restaurant, Community College, Arcade', '', -6.898180, 107.644997, 0, '0227275855', '', 'Jalan Cikutra No. 204 A', '', 'Bandung', 'Indonesia', '40125', 'Indonesia'),
('4b17a350f964a520bfc623e3', 'Mood food', 'Middle Eastern Restaurant', '', 55.667999, 12.549200, 0, '', '', '', '', '', '', '', ''),
('4cae16c318a3199cfe015cfb', 'Sidsels', 'Home', '', 55.664902, 12.582200, 0, '', '', '', '', '', '', '', ''),
('4cf521048333224b56821e8e', 'Good Food', 'Salad Place', '', 55.680901, 12.578200, 0, '', '', '', '', '', '', '', ''),
('4ceb2f50baa6a1cd33343d6c', 'FOODCOURT SMAN 19 Bandung', '', '', -6.873400, 107.619003, 0, '', '', 'Jl. Ir.H Juanda', 'Dago Pojok', 'Bandung', 'West Java', '', ''),
('4c46b4671262ef3b8413c941', 'Food Court Toserba Griya Pahlawan', 'Food Court, Fast Food Restaurant', '', -6.893100, 107.635002, 0, '', '', '', '', '', '', '', ''),
('4cf7655668025941d85c6d73', 'Food Court Universitas Widyatama', 'Food Court', '', -6.898140, 107.646004, 0, '0227275855', '', 'Jl Cikutra No 204 A', '', 'Bandung', 'Indonesia', '40125', ''),
('4cda4e36930af04de82b8497', 'Foodcourt (Universitas Widyatama)', 'Food Court', '', -6.900120, 107.642998, 0, '', '', '', '', '', '', '', ''),
('4bfb6a15633d9c748b440843', 'Tubiz Foodcourt', 'Food Court', '', -6.885060, 107.619003, 0, '', '', '', '', '', '', '', ''),
('4c021c0398f60f47fe13cda4', 'Lisung Dago Pakar', 'CafÃ©, Asian Restaurant, Diner, Restaurant, Arcade', '', -6.912430, 107.607002, 0, '', '', '', '', '', '', '', ''),
('4c29d85b97d00f470df541ea', 'The kiost braga citywalk', 'Food Court', '', -6.917120, 107.609001, 0, '', '', '', '', '', '', '', ''),
('4c39fcf5dfb0e21ebd50b1a8', 'Mc Donald''s Cihampelas', 'Fast Food Restaurant', '', -6.896430, 107.603996, 0, '', '', '', '', '', '', '', ''),
('4be9148488ed2d7ff696cc1d', 'Batagor Riri', 'Asian Restaurant', '', -6.925410, 107.620003, 0, '', '', '', '', '', '', '', ''),
('4c1aedb40137952158ca46f3', 'Kantin Cahaya', 'Restaurant', '', -6.885640, 107.582001, 0, '', '', '', '', '', '', '', ''),
('4cff32b44f56b60c8a7e9b37', 'D''seuhah da lada', 'Food Truck', '', -6.819160, 107.612000, 0, '', '', '', '', '', '', '', ''),
('4b8f95aff964a520f35833e3', 'Food Court BSM', 'Food Court', '', -6.926520, 107.637001, 0, '', '', '', '', '', '', '', ''),
('4bd6cef1637ba5938fabf870', 'Community Ciumbuleuit 70', 'Laundromat or Dry Cleaner, Department Store, Building', '', -6.870660, 107.606003, 0, '', '', '', '', '', '', '', ''),
('4c03278ff423a593d2efcf16', 'Food Court Widyatama', 'Food Court', '', -6.901060, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4bdfbf02e75c0f47f03ecc03', 'Jalaprang Street Food Court', 'CafÃ©', '', -6.897280, 107.630997, 0, '', '', '', '', '', '', '', ''),
('4bfc9a8ff61dc9b63bef9dde', 'Food Activita Universitas Widyatama', 'Food Court', '', -6.900120, 107.642998, 0, '', '', '', '', '', '', '', ''),
('4c42ebded7fad13a88cd09da', 'Batak''s Food', 'BBQ Joint', '', -6.901390, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4d636e5061dda143d0671d18', 'MCCF (MULYA CIREBON CHINESSE FOOD)', 'Asian Restaurant', '', -6.885060, 107.619003, 0, '', '', '', '', '', '', '', ''),
('4ccdb6712dc43704df21d008', 'Libas Food Court', '', '', -6.896190, 107.629997, 0, '', '', '', '', '', '', '', ''),
('4c2f1eafa0ced13a90f50f6e', 'Food court Bandung indah plaza', 'Arcade', '', -6.874490, 107.616997, 0, '', '', 'Jln merdeka', '', '', '', '', ''),
('4bc96de2cc8cd13a02afbbcf', 'tubis foodcourt', 'Food Court', '', -6.885060, 107.619003, 0, '', '', '', '', '', '', '', ''),
('4c5eaacaed29ef3b961b9e76', 'Katio Chinese Food', 'Chinese Restaurant', '', -6.877810, 107.619003, 0, '', '', 'Jl.Kanayakan No.344/3', '', 'Bandung', 'Jawa Barat', '', ''),
('4bfe3f2855539c74d7cfbcf3', 'Pahlawan Street Food Court', 'Food Court, Food Truck', '', -6.892720, 107.635002, 0, '', '', 'Jalan Pahlawan', '', 'Bandung', 'Jawa Barat Indonesia', '', ''),
('4c1a30f898f4a593542b01f6', 'Hiroz Futsal & Food Corner', 'Food Court', '', -6.893100, 107.635002, 0, '', '', 'Jl. Pahlawan No.43', '', 'Bandung Regency', 'West Java', '', ''),
('4c7928fca86837049f7b0f4d', 'Pepirooz Poolside Restaurant', 'Breakfast Spot', '', -6.863890, 107.614998, 0, '', '', '', '', '', '', '', ''),
('4c2f0083a0ced13a35d40f6e', 'Fashion Pasta', 'Wine Bar', '', -6.862680, 107.637001, 0, '', '', '', '', '', '', '', ''),
('4be10d86c1732d7feb315b9a', 'Warung inul', 'Restaurant', '', -6.861860, 107.652000, 0, '', '', '', '', '', '', '', ''),
('4d8211ecebb4236a807e4b58', 'Cupcake milo', '', '', -6.860060, 107.653000, 0, '', '', '', '', '', '', '', ''),
('4c25857e5c5ca5931fac44fe', 'Warung Cikur Nur', 'Restaurant', '', -6.861920, 107.652000, 0, '', '', '', '', '', '', '', ''),
('4d436721bf61a1cd4dacfdab', 'Husky Play Land', 'Dog Run', '', -6.862210, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4c3c095186ce328f8745ab2d', 'Warung Nasi Karasak', 'Asian Restaurant', '', -6.861280, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4d43eff51928a35dee78b370', 'Private Gym', 'Gym', '', -6.861690, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4b9527edf964a520289234e3', 'Cloud 9', 'Bar, Lounge, Arcade, CafÃ©, Rock Club, Beer Garden', '', -6.844710, 107.630997, 0, '', '', '', '', '', '', '', ''),
('4c0933617e3fc928c289f182', 'Galleri 125', 'Art Gallery', '', 55.670700, 12.542000, 0, '', '', '', '', '', '', '', ''),
('4b6aeaf1f964a520d2e62be3', 'Urtehuset', 'Grocery Store', '', 55.700100, 12.577300, 0, '', '', '', '', '', '', '', ''),
('4cb122f96c269521402cb8d9', 'Balai Desa Cileles', '', '', -6.858600, 107.649002, 0, '', '', '', '', '', '', '', ''),
('4cdc13583f6a8cfa9512efea', 'Lindy''s crib', '', '', -6.859160, 107.650002, 0, '', '', '', '', '', '', '', ''),
('4c8b4b47770fb60c82b7dac3', 'Villa Messa Kiki n Nena Hasan', '', '', -6.861730, 107.654999, 0, '', '', '', '', '', '', '', ''),
('4c52dc5e94790f47538b29a3', 'Ralph', '', '', 51.523701, -0.076494, 0, '', '', '', '', '', '', '', ''),
('4ad75c2df964a520cd0921e3', 'Pizza East', 'Pizza Place, Italian Restaurant', '', 51.523899, -0.077208, 0, '', '', '', '', '', '', '', ''),
('4d821aa01ec4224b0028d492', 'Cupcake baby L', '', '', -6.860330, 107.653000, 0, '', '', '', '', '', '', '', ''),
('4d0d7809d515236a56a00d4b', 'Lembah pakar', '', '', -6.859970, 107.651001, 0, '', '', '', '', '', '', '', ''),
('4ca86de3f47ea1435dde7421', 'Pondok Bunda Lestari', '', '', -6.859160, 107.650002, 0, '', '', '', '', '', '', '', ''),
('4d94a035af67370476558009', 'Ciburial, Dago Atas', '', '', -6.860550, 107.650002, 0, '', '', '', '', '', '', '', ''),
('4cdf9d7edf986ea81058e316', 'Kandang Yosep', '', '', -6.857470, 107.650002, 0, '', '', '', '', '', '', '', ''),
('4c007eda8c1076b0164e2071', 'Theater Room', 'Indie Movie Theater', '', -6.861140, 107.648003, 0, '', '', '', '', '', '', '', ''),
('4c74bac8c219224b37b6a028', 'Priority lounge Grapari Bandung', '', '', -6.861500, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4c15846f1b5cef3bf64eeec4', 'TV DPM 33', 'Religious Center', '', -6.861240, 107.647003, 0, '', '', '', '', '', '', '', ''),
('4c023be9f56c2d7fdc2a1b66', 'Club house graha kencana', 'Pool', '', -6.857350, 107.651001, 0, '', '', '', '', '', '', '', ''),
('4cc0c20c873c236afdafb423', 'Aiport dago pakar', '', '', -6.862310, 107.648003, 0, '', '', '', '', '', '', '', ''),
('4d5a53ca5e7788bfe5b08c9e', 'Kencana Resort Club', 'Pool, Gym', '', -6.861160, 107.648003, 0, '', '', '', '', '', '', '', ''),
('4cf4c75894feb1f7f1a829ba', 'Badung Food & Beverages', '', '', -6.869860, 107.620003, 0, '', '', 'Padjajaran', '', 'Bandung', 'West Java', '', ''),
('4c78eefc81bca0934aa2fb14', 'Cabe rawit cafe', '', '', -6.876260, 107.623001, 0, '', '', 'Dago', '', 'Bandung', 'West Java', '', ''),
('4ca95415a6e08cfada7d9894', 'Foodcourt widyatama', 'Arcade', '', -6.898400, 107.643997, 0, '', '', '', '', 'Bandung', 'West Java', '', ''),
('4d05c58fe350b60c05318a42', 'Food Festivita', 'Food Court', '', -6.898660, 107.643997, 0, '', '', '', 'Jl. Cikutra No. 204A', 'Bandung', 'West Java', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `fs_id` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `access` varchar(10) NOT NULL COMMENT 'pending/allow/deny',
  PRIMARY KEY  (`fs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`fs_id`, `name`, `access`) VALUES
('1559921', 'Evan Gozali', 'allow'),
('2497639', 'Tash Wisdom', 'allow'),
('91515', 'Tony Hanna', 'allow');

-- --------------------------------------------------------

--
-- Table structure for table `users_places`
--

CREATE TABLE IF NOT EXISTS `users_places` (
  `user_id` varchar(50) NOT NULL,
  `place_id` varchar(50) NOT NULL,
  PRIMARY KEY  (`user_id`,`place_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_places`
--

INSERT INTO `users_places` (`user_id`, `place_id`) VALUES
('1559921', ''),
('1559921', '(null)'),
('1559921', '4bee3153e24d20a186b27214'),
('1559921', '4bfe3f2855539c74d7cfbcf3'),
('1559921', '4c1a30f898f4a593542b01f6'),
('1559921', '4c5eaacaed29ef3b961b9e76'),
('1559921', '4c78eefc81bca0934aa2fb14'),
('1559921', '4ceb2f50baa6a1cd33343d6c'),
('1559921', '4cf4c75894feb1f7f1a829ba'),
('2497639', '4ad75c2df964a520cd0921e3'),
('2497639', '4c52dc5e94790f47538b29a3'),
('91515', '4b17a350f964a520bfc623e3'),
('91515', '4b6aeaf1f964a520d2e62be3'),
('91515', '4c0933617e3fc928c289f182'),
('91515', '4cf521048333224b56821e8e');
