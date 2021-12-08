/*Insert procedure for Shift Type Master Table*/
CREATE OR REPLACE PROCEDURE insertShiftMaster (stype CHAR, sstart TIMESTAMP, send TIMESTAMP) IS
BEGIN
    INSERT INTO shifts_type_master (shift_type, start_time, end_time)
    VALUES (stype, sstart, send);
END;
/

/*Insert procedure for Proctor Table*/
CREATE OR REPLACE PROCEDURE insertProctor (pname VARCHAR, pcontact VARCHAR, pemail VARCHAR, paddress VARCHAR, pdob VARCHAR) IS
BEGIN
    INSERT INTO proctor (proctor_name, proctor_contact, proctor_email, proctor_address, proctor_dob)
    VALUES (pname, pcontact, pemail, paddress, pdob);
END;
/

/*Insert procedure for Supervisors Table*/
CREATE OR REPLACE PROCEDURE insertSupervisor (supname VARCHAR, supaddress VARCHAR, supcontact VARCHAR, supemail VARCHAR) IS
BEGIN
    INSERT INTO supervisor (supervisor_name, supervisor_address, supervisor_contact, supervisor_email)
    VALUES (supname, supaddress, supcontact, supemail);
END;
/

/*Insert Proctor data*/
BEGIN
    insertProctor('Tabbatha McCahey','(202) 4623202','tmccahey0@gmpg.org','143 Schiller Parkway','14-Jan-1994');
    insertProctor('Ilysa Fullard','(241) 6124835','ifullard1@shutterfly.com','07 Haas Place','28-May-2000');
    insertProctor('Dana Dimock','(640) 7523291','ddimock2@tmall.com','5632 Muir Court','15-Sep-1988');
    insertProctor('Brandise Mertel','(465) 5295897','bmertel3@businesswire.com','2821 Pleasure Hill','27-May-2000');
    insertProctor('Wallache Westwood','(177) 3077742','wwestwood4@studiopress.com','4 Maple Way','24-Feb-1991');
    insertProctor('Emmett Sommerlin','(154) 7179576','esommerlin5@ucla.edu','4132 Westend Drive','17-May-1998');
    insertProctor('Lisbeth Ceillier','(996) 3592878','lceillier6@etsy.com','5 Little Fleur Terrace','24-Mar-1991');
    insertProctor('Jennine Mattingley','(670) 2276239','jmattingley7@adobe.com','89 Surrey Trail','03-Jul-1987');
    insertProctor('Edsel Fordy','(799) 4405545','efordy8@china.com.cn','7350 Onsgard Terrace','14-Jan-1988');
    insertProctor('Shel Mitten','(683) 1493914','smitten9@miibeian.gov.cn','10251 Corry Park','15-Jul-2000');
    insertProctor('Tony Fessions','(938) 3380897','tfessionsa@businessweek.com','7253 Loomis Pass','21-Dec-1999');
    insertProctor('Fabian Wildish','(936) 9371949','fwildishb@opensource.org','5 Sullivan Circle','30-Dec-1994');
    insertProctor('Vaughn Walsh','(690) 2044883','vwalshc@cmu.edu','60811 Elka Center','03-Mar-2003');
    insertProctor('Sheeree Canedo','(379) 9352394','scanedod@feedburner.com','03 Nevada Park','09-Oct-1985');
    insertProctor('Jana Patnelli','(730) 4823611','jpatnellie@unc.edu','13 Memorial Trail','18-Dec-1995');
    insertProctor('Skipton Allardyce','(544) 5703289','sallardycef@springer.com','14019 Kings Hill','22-May-1991');
    insertProctor('Anatol Butterick','(442) 4801542','abutterickg@omniture.com','6491 Atwood Junction','29-Apr-2000');
    insertProctor('Xaviera Simpole','(990) 6810987','xsimpoleh@github.io','2 Ridgeview Trail','13-Sep-1986');
    insertProctor('Clo Nolot','(842) 7552035','cnoloti@newsvine.com','252 Gina Terrace','31-Jul-1985');
    insertProctor('Corri McCollum','(249) 4700549','cmccollumj@apache.org','813 Killdeer Drive','16-Oct-1992');
    insertProctor('Kiri Druhan','(863) 5340603','kdruhank@nydailynews.com','4 Holmberg Circle','13-Oct-1993');
    insertProctor('Kristine Ingleson','(779) 8158059','kinglesonl@examiner.com','8 Knutson Street','06-Mar-1995');
    insertProctor('Waldo Cooke','(376) 5930313','wcookem@independent.co.uk','3885 Mandrake Place','25-Mar-1998');
    insertProctor('Dorita Benazet','(473) 8018692','dbenazetn@aboutads.info','10457 Springview Plaza','26-Jul-1996');
    insertProctor('Rolland Kobisch','(795) 3825932','rkobischo@state.gov','530 Summer Ridge Center','10-Jan-1990');
    insertProctor('Imogene Glassborow','(568) 7069297','iglassborowp@nih.gov','0 High Crossing Way','21-Feb-1998');
    insertProctor('Corliss Durtnel','(675) 1538337','cdurtnelq@cbc.ca','85 Express Pass','07-Jun-2002');
    insertProctor('Luca Benjamin','(108) 4477724','lbenjaminr@globo.com','67293 Fuller Avenue','27-Dec-2002');
    insertProctor('Astrid Wedgbrow','(146) 9584886','awedgbrows@skyrock.com','736 Maple Parkway','20-Jun-1985');
    insertProctor('Coletta Rillatt','(544) 2787464','crillattt@usa.gov','284 Loomis Terrace','11-May-1999');
    insertProctor('Hedvige Aldin','(712) 3502252','haldinu@cyberchimps.com','4 Johnson Terrace','26-Oct-1994');
    insertProctor('Bertie Drain','(191) 5705964','bdrainv@google.co.uk','0 Glendale Hill','10-Jul-1991');
    insertProctor('Shermie Seston','(880) 4155777','ssestonw@xing.com','8 Browning Alley','10-Mar-1987');
    insertProctor('Barri Micka','(242) 8322992','bmickax@bing.com','0 Quincy Way','02-Dec-1998');
    insertProctor('Skippy Campkin','(978) 5818543','scampkiny@reddit.com','1 Elka Point','26-May-1994');
    insertProctor('Morena Demeza','(296) 9049583','mdemezaz@walmart.com','3832 Anniversary Park','22-Mar-1995');
    insertProctor('Renault Gajownik','(637) 8370789','rgajownik10@simplemachines.org','64595 Di Loreto Center','22-Feb-1999');
    insertProctor('Kevina Premble','(783) 3941639','kpremble11@behance.net','5460 Melrose Parkway','23-May-1999');
    insertProctor('Vonnie Chiles','(378) 3635516','vchiles12@umich.edu','2 Killdeer Point','03-Sep-1999');
    insertProctor('Shelba Gwilliams','(407) 7570814','sgwilliams13@ucoz.com','9 Northland Lane','22-Mar-2003');
    insertProctor('Lanny Willison','(588) 1960283','lwillison14@google.pl','8 Barnett Street','04-Dec-1996');
    insertProctor('Georg Laurand','(121) 7163453','glaurand15@fda.gov','5173 Mockingbird Point','18-Nov-1990');
    insertProctor('Sophi Duxbarry','(956) 2773458','sduxbarry16@wix.com','5713 Parkside Pass','01-Jul-2003');
    insertProctor('Georgeanne Sabey','(513) 4332022','gsabey17@weather.com','3 Farmco Terrace','08-Jul-1997');
    insertProctor('Tannie Bagniuk','(646) 8086371','tbagniuk18@ezinearticles.com','17 Amoth Drive','15-May-1998');
    insertProctor('Sandi Hardington','(565) 4226108','shardington19@reference.com','750 Buhler Place','15-Mar-2002');
    insertProctor('Elisabeth Paulmann','(547) 2709116','epaulmann1a@youtu.be','326 Saint Paul Trail','13-Mar-1994');
    insertProctor('Kit Quinney','(882) 6607718','kquinney1b@amazon.com','3 Milwaukee Street','22-Mar-1997');
    insertProctor('Iago Larrett','(989) 5770555','ilarrett1c@cornell.edu','4029 Shasta Avenue','26-May-1988');
    insertProctor('Karna Jillis','(251) 8293901','kjillis1d@ebay.com','02594 Nobel Court','03-Mar-1986');
    insertProctor('Rosa Dugan','(725) 2111768','rdugan1e@e-recht24.de','3 Hauk Lane','25-Feb-1991');
    insertProctor('Avis Humbee','(213) 4465920','ahumbee1f@wired.com','93302 Oriole Park','29-Nov-2002');
    insertProctor('Ward Cuttelar','(332) 2216878','wcuttelar1g@amazon.co.uk','9251 Commercial Pass','01-Nov-1994');
    insertProctor('Dyana Noni','(540) 4561198','dnoni1h@army.mil','660 Stone Corner Junction','06-Nov-1995');
    insertProctor('Deena Bannerman','(531) 8497132','dbannerman1i@jimdo.com','601 Caliangt Place','13-May-1989');
    insertProctor('Maximo Strawbridge','(863) 2464317','mstrawbridge1j@parallels.com','6 Main Avenue','22-Nov-1985');
    insertProctor('Demetris Bentham3','(831) 2395872','dbentham1k@fema.gov','90 Michigan Terrace','31-May-2000');
    insertProctor('Drusy Margiotta','(173) 8193038','dmargiotta1l@google.de','3893 Kennedy Junction','01-Nov-1988');
    insertProctor('Ashli Judron','(924) 9177488','ajudron1m@newsvine.com','2993 Holy Cross Center','30-Jul-1986');
    insertProctor('Brina Muskett','(857) 5571535','bmuskett1n@bbb.org','57 Roxbury Plaza','11-Sep-1995');
    insertProctor('Daria Scopyn','(563) 1286838','dscopyn1o@webeden.co.uk','98902 Eastlawn Way','25-Jan-1999');
    insertProctor('Neal Vurley','(497) 4255070','nvurley1p@wunderground.com','39162 Di Loreto Street','04-Sep-1989');
    insertProctor('Maire Rikel','(284) 1270943','mrikel1q@issuu.com','34166 Moulton Lane','01-May-1987');
    insertProctor('Abbot Dougal','(571) 8720969','adougal1r@nbcnews.com','904 Lawn Park','26-Dec-1989');
    insertProctor('Elnar Capaldi','(854) 8504540','ecapaldi1s@yellowbook.com','138 Charing Cross Road','28-Feb-1987');
    insertProctor('Amalie Filippucci','(883) 7732508','afilippucci1t@mediafire.com','505 Gulseth Trail','22-May-1999');
    insertProctor('Saundra Hallor','(735) 3339701','shallor1u@intel.com','9675 Eagle Crest Street','26-May-2000');
    insertProctor('Ty Swindon','(991) 1419226','tswindon1v@narod.ru','71269 Lillian Crossing','12-Jul-1993');
    insertProctor('Zea O Loughnan','(998) 7282052','zoloughnan1w@sohu.com','2 Russell Drive','06-May-1990');
    insertProctor('Lucius Kennifick','(414) 1027211','lkennifick1x@barnesandnoble.com','4218 Northfield Junction','31-May-1991');
    insertProctor('Gerianna Curnick','(447) 7544119','gcurnick1y@163.com','90492 Kings Hill','28-Mar-2003');
    insertProctor('Renelle Knock','(547) 2906362','rknock1z@nyu.edu','43 John Wall Drive','27-Apr-1995');
    insertProctor('Susan Spellacey','(245) 2727544','sspellacey20@flickr.com','12 Duke Junction','03-Mar-1986');
    insertProctor('Cross Basezzi','(829) 9353194','cbasezzi21@jigsy.com','3430 Kim Pass','20-Dec-1993');
    insertProctor('Pauly Crosthwaite','(746) 3807309','pcrosthwaite22@nba.com','4241 Stang Place','13-Mar-1990');
    insertProctor('Godfrey Dwelly','(766) 3198648','gdwelly23@answers.com','8 Delladonna Trail','31-Dec-1992');
    insertProctor('Deloria Asey','(993) 8540506','dasey24@google.com.hk','62 Monica Park','07-May-1988');
    insertProctor('Clarabelle Goodbarr','(817) 6351200','cgoodbarr25@mayoclinic.com','159 Banding Place','03-Dec-1997');
    insertProctor('Betsy Cottie','(349) 1883779','bcottie26@edublogs.org','33 Tennyson Terrace','04-Oct-1998');
    insertProctor('Nathalie Rajchert','(719) 5961558','nrajchert27@linkedin.com','3893 Toban Road','30-Jan-1997');
    insertProctor('Jarvis Vickerman','(374) 9435515','jvickerman28@twitpic.com','93873 Bunting Drive','12-Jan-1987');
    insertProctor('Miran Mitkov','(228) 8169093','mmitkov29@homestead.com','5770 Waxwing Drive','02-Jun-1997');
    insertProctor('Gardener Criag','(923) 4115027','gcriag2a@answers.com','13126 Cardinal Lane','31-Mar-1996');
    insertProctor('Ervin Szymanski','(931) 3654362','eszymanski2b@clickbank.net','09 Fairfield Trail','12-May-1988');
    insertProctor('Kaile Sprague','(136) 8501005','ksprague2c@yahoo.co.jp','062 Clyde Gallagher Alley','02-Jan-2003');
    insertProctor('Berti Babb','(225) 8055488','bbabb2d@tripadvisor.com','0 Maple Wood Parkway','05-May-1994');
    insertProctor('Luther Armal','(204) 2175547','larmal2e@sbwire.com','7919 Mallory Center','16-Oct-1993');
    insertProctor('Pablo Etchell','(258) 7418682','petchell2f@examiner.com','57944 Springs Crossing','01-Feb-1997');
    insertProctor('Ingeberg Lorkins','(737) 1418639','ilorkins2g@sohu.com','4 Marcy Crossing','08-Feb-1998');
    insertProctor('Saudra Bohea','(175) 7838999','sbohea2h@webs.com','5092 Havey Circle','05-Aug-1991');
    insertProctor('Olivia Duffield','(487) 7528440','oduffield2i@europa.eu','3410 Granby Trail','08-Jan-1989');
    insertProctor('Karlen Warsap','(324) 6531175','kwarsap2j@techcrunch.com','56 Grover Way','20-Nov-1989');
    insertProctor('Daryl De Mitri','(224) 9141292','dde2k@wunderground.com','70621 Sutteridge Center','04-Sep-1994');
    insertProctor('Frannie Davidai','(961) 7290191','fdavidai2l@google.es','5 Rockefeller Trail','27-Nov-1996');
    insertProctor('Violetta Girodin','(865) 4153507','vgirodin2m@google.ru','3 Esch Hill','24-Jan-1998');
    insertProctor('Edgar Coutts','(252) 2997668','ecoutts2n@homestead.com','08462 Red Cloud Park','19-Dec-1993');
    insertProctor('Ealasaid Sellstrom','(935) 5461920','esellstrom2o@lulu.com','8374 Shelley Hill','11-Feb-2001');
    insertProctor('Douglas Depport','(311) 1596507','ddepport2p@walmart.com','52887 Continental Crossing','24-Sep-1987');
    insertProctor('Tiertza Semken','(280) 5851079','tsemken2q@sakura.ne.jp','3 Autumn Leaf Plaza','20-Aug-1986');
END;
/

/*Insert Supervisor data*/
BEGIN
    insertSupervisor('Ryley Scrivin','7842 Longview Way','(972) 9294324','rscrivin0@geocities.com');
    insertSupervisor('Roddie Lurriman','6 Granby Parkway','(682) 8855719','rlurriman1@stanford.edu');
    insertSupervisor('Tiffy O Deoran','653 Surrey Way','(853) 2811364','todeoran2@netlog.com');
    insertSupervisor('Garwin Grimston','5 Glacier Hill Place','(554) 6005270','ggrimston3@gov.uk');
    insertSupervisor('Devondra Sweeten','42 Dixon Point','(991) 1032260','dsweeten4@last.fm');
    insertSupervisor('Curr Augustine','0 Scoville Parkway','(649) 2290491','caugustine5@hibu.com');
    insertSupervisor('Julie O Rowane','7 Division Parkway','(825) 4420104','jorowane6@hp.com');
    insertSupervisor('Mordecai Pieters','43740 Helena Plaza','(871) 7771832','mpieters7@globo.com');
    insertSupervisor('Keefe Sidry','133 Gerald Avenue','(876) 7687957','ksidry8@hhs.gov');
    insertSupervisor('Ilyse Springall','8748 Red Cloud Park','(229) 5036477','ispringall9@google.cn');
    insertSupervisor('Novelia Harly','0757 Butternut Place','(302) 3326366','nharlya@timesonline.co.uk');
    insertSupervisor('Tully Betz','2216 Milwaukee Circle','(441) 7700490','tbetzb@census.gov');
    insertSupervisor('Paddie Hamberstone','100 Weeping Birch Lane','(357) 6904517','phamberstonec@icq.com');
    insertSupervisor('Pooh Melross','8 Shoshone Junction','(804) 4637144','pmelrossd@i2i.jp');
    insertSupervisor('Jerry McCobb','703 Orin Drive','(131) 1016502','jmccobbe@shinystat.com');
    insertSupervisor('Eben Sandom','0 Meadow Valley Avenue','(315) 2518963','esandomf@dedecms.com');
    insertSupervisor('Ashly Kochlin','126 Ludington Crossing','(927) 2309984','akochling@vistaprint.com');
    insertSupervisor('Drusie Adney','22 Briar Crest Circle','(261) 4626886','dadneyh@creativecommons.org');
    insertSupervisor('Hans Coopey','29 Calypso Place','(166) 5127107','hcoopeyi@flickr.com');
    insertSupervisor('Viv Kemster','9645 Kingsford Crossing','(413) 8925628','vkemsterj@1und1.de');
END;
/

/*Insert Shift Type Master Data*/
BEGIN
    insertShiftMaster('A', TO_TIMESTAMP('00:00:00', 'hh24:mi:ss') , TO_TIMESTAMP('08:00:00', 'hh24:mi:ss'));
    insertShiftMaster('B', TO_TIMESTAMP('08:00:00', 'hh24:mi:ss') , TO_TIMESTAMP('16:00:00', 'hh24:mi:ss'));
    insertShiftMaster('C', TO_TIMESTAMP('16:00:00', 'hh24:mi:ss') , TO_TIMESTAMP('00:00:00', 'hh24:mi:ss'));
END;
/

select * from shifts_type_master;
--truncate table shifts_type_master;
