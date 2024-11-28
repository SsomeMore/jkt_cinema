  INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES ('cinema_ticket', 'Cinema Ticket', 10, 1, 'item_standard', 1, 'A ticket to watch movie at cinema.')
    ON DUPLICATE KEY UPDATE `item`='cinema_ticket', `label`='Cinema Ticket', `limit`=10, `can_remove`=1, `type`='item_standard', `usable`=1, `desc` = 'A ticket to watch movie at cinema.';
