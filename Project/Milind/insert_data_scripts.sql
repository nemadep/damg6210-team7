/*Insert procedure for Police Table*/
CREATE OR REPLACE PROCEDURE insertPolice (policename VARCHAR, policegender CHAR, policecontact VARCHAR) IS
BEGIN
    INSERT INTO police (police_name, police_gender, police_contact)
    VALUES (policename, policegender, policecontact);
END;
/

/*Insert Police Data*/
BEGIN
    insertPolice('Netty Chaman', 'F', '(575) 5845382');
	insertPolice('Launce Jacobssen', 'M', '(205) 3514451');
	insertPolice('Quinn Barnsdale', 'M', '(836) 4735821');
	insertPolice('Bunny de Broke', 'F', '(206) 1664037');
	insertPolice('Rodrigo Jenno', 'M', '(354) 2129722');
	insertPolice('Manfred Heigho', 'M', '(189) 1843071');
	insertPolice('Gilberta Lindl', 'F', '(176) 6915209');
	insertPolice('Stanleigh McManus', 'M', '(562) 3307811');
	insertPolice('Rabi Tuxwell', 'M', '(497) 2651712');
	insertPolice('Fanni Gwyther', 'F', '(595) 9536722');
	insertPolice('Sydney Hryskiewicz', 'M', '(348) 5383026');
	insertPolice('Bud Stoacley', 'M', '(971) 9175866');
	insertPolice('Neal Riepl', 'M', '(829) 3123670');
	insertPolice('Dorthea Thebeaud', 'F', '(490) 5207986');
	insertPolice('Morgan Anslow', 'M', '(159) 1492591');
	insertPolice('Ina Mewton', 'F', '(724) 4234622');
	insertPolice('Helen-elizabeth Scuse', 'F', '(248) 3778059');
	insertPolice('Kayla Tomalin', 'F', '(145) 9205869');
	insertPolice('Seymour Feldstein', 'M', '(887) 2837754');
	insertPolice('Zorina Lawrey', 'F', '(797) 3622336');
	insertPolice('Amandy Berecloth', 'F', '(229) 4498464');
	insertPolice('Claybourne Korba', 'M', '(950) 8790392');
	insertPolice('Romain Tinkler', 'M', '(613) 5917243');
	insertPolice('Dierdre Mobbs', 'F', '(795) 9034100');
	insertPolice('Veronika Biesterfeld', 'F', '(516) 8082160');
	insertPolice('Celka Sausman', 'F', '(380) 2138072');
	insertPolice('Salomi Sanbrooke', 'F', '(491) 5965973');
	insertPolice('Findley Jeavons', 'M', '(133) 5158050');
	insertPolice('Rose Hollows', 'F', '(796) 4030955');
	insertPolice('Jeana De Fraine', 'F', '(411) 1874525');
	insertPolice('Gothart Neumann', 'M', '(227) 1332650');
	insertPolice('Elyse Yewdall', 'F', '(735) 6959266');
	insertPolice('Lionello Henniger', 'M', '(601) 5239510');
	insertPolice('Marin Heathwood', 'F', '(877) 6726823');
	insertPolice('Izzy Grinaugh', 'M', '(898) 7197153');
	insertPolice('Kermie Labusch', 'M', '(310) 8692523');
	insertPolice('Corey Mosconi', 'M', '(390) 2417034');
	insertPolice('Loria Gallaccio', 'F', '(707) 7774352');
	insertPolice('Matelda Cadle', 'F', '(681) 1742311');
	insertPolice('Reece Kuhnt', 'M', '(976) 9824411');
	insertPolice('Mart Ogbourne', 'M', '(174) 9842303');
	insertPolice('Karleen Pollard', 'F', '(579) 6511336');
	insertPolice('Abbie Case', 'F', '(584) 8256647');
	insertPolice('Cele Fieldgate', 'F', '(811) 6695259');
	insertPolice('Gearard Mazzey', 'M', '(132) 6618331');
	insertPolice('Heida Arsey', 'F', '(988) 5399831');
	insertPolice('Xenia Eddy', 'F', '(793) 5131320');
	insertPolice('Lulita Benitez', 'F', '(816) 4692770');
	insertPolice('Ernesta Bowie', 'F', '(400) 4763959');
	insertPolice('Zaccaria Ondrasek', 'M', '(454) 4978252');

END;
/