--Student ID: 27620611
--Student Fullname: Thomas Birkenes
--Tutor Name: Shirin Maghool

/*  --- COMMENTS TO YOUR MARKER --------


*/

--Q1
/*
1.1
Add to your solutions script, the CREATE TABLE and CONSTRAINT definitions which are missing from the 
FIT9132_2018S2_A2_Schema_Start.sql script. You MUST use the relation and attribute names shown in the data model above 
to name tables and attributes which you add.
*/

CREATE TABLE book_copy (
    branch_code         NUMERIC(2) NOT NULL,
    bc_id               NUMERIC(6) NOT NULL,
    bc_purchase_price   NUMERIC(7,2),
    bc_reserve_flag     CHAR(1) NOT NULL,
    book_call_no        VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_book_copy PRIMARY KEY ( branch_code,
                                          bc_id )
);

ALTER TABLE book_copy
    ADD CONSTRAINT bc_reserve_flag_chk CHECK ( bc_reserve_flag IN (
        'R',
        'L'
    ) );

ALTER TABLE book_copy ADD CONSTRAINT chk_bc_unique UNIQUE ( bc_id,
                                                            branch_code );

ALTER TABLE book_copy ADD CONSTRAINT bc_purchase_chk CHECK ( bc_purchase_price >= 0 );

COMMENT ON COLUMN book_copy.branch_code IS
    'Branch number ';

COMMENT ON COLUMN book_copy.bc_id IS
    'Book copy id number';

COMMENT ON COLUMN book_copy.bc_purchase_price IS
    'Book copy purchase price ';

COMMENT ON COLUMN book_copy.bc_reserve_flag IS
    '(R)Reserve flag - and not availabe for (L)loan, R is not available for loan';

COMMENT ON COLUMN book_copy.book_call_no IS
    'Titles call number - identifies a title';

CREATE TABLE reserve (
    branch_code                NUMERIC(2) NOT NULL,
    bc_id                      NUMERIC(6) NOT NULL,
    reserve_date_time_placed   DATE NOT NULL,
    bor_no                     NUMERIC(6) NOT NULL,
    CONSTRAINT pk_reserve PRIMARY KEY ( branch_code,
                                        bc_id,
                                        reserve_date_time_placed )
);

COMMENT ON COLUMN reserve.branch_code IS
    'Branch number ';

COMMENT ON COLUMN reserve.bc_id IS
    'Book copy id number';

COMMENT ON COLUMN reserve.reserve_date_time_placed IS
    'Reasonable date only allowed';

COMMENT ON COLUMN reserve.bor_no IS
    'Borrower identifier';

ALTER TABLE reserve
    ADD CONSTRAINT reasonable_date CHECK ( reserve_date_time_placed IS NOT NULL
                                           AND TO_CHAR(reserve_date_time_placed,'dd/mm/yyyy hh:mm:ss') >= '01/01/2018 00:00:00' )
                                           ;

CREATE TABLE loan (
    branch_code               NUMERIC(2) NOT NULL,
    bc_id                     NUMERIC(6) NOT NULL,
    loan_date_time            DATE NOT NULL,
    loan_due_date             DATE NOT NULL,
    loan_actual_return_date   DATE,
    bor_no                    NUMERIC(6) NOT NULL,
    CONSTRAINT pk_loan PRIMARY KEY ( branch_code,
                                     bc_id,
                                     loan_date_time )
);

ALTER TABLE loan ADD (
    CONSTRAINT date_loan_chk CHECK ( TO_CHAR(loan_date_time,'dd/mm/yyyy hh:mm:ss') >= '01/01/2018 00:00:00' )
);

ALTER TABLE loan ADD (
    CONSTRAINT date_due_chk CHECK ( TO_CHAR(loan_due_date,'dd/mm/yyyy') >= '01/01/2018' )
);

ALTER TABLE loan ADD (
    CONSTRAINT actual_return_chk CHECK ( TO_CHAR(loan_actual_return_date,'dd/mm/yyyy') >= '01/01/2018' )
);

COMMENT ON COLUMN loan.branch_code IS
    'Branch number ';

COMMENT ON COLUMN loan.bc_id IS
    'Book copy id number';

COMMENT ON COLUMN loan.loan_date_time IS
    'Loan start date';

COMMENT ON COLUMN loan.loan_due_date IS
    'Due date for returning book';

COMMENT ON COLUMN loan.loan_actual_return_date IS
    'Actual return time of the book';

COMMENT ON COLUMN loan.bor_no IS
    'Borrower identifier';


/*
Foreign keys addition
*/

ALTER TABLE book_copy
    ADD CONSTRAINT fk_bc_branch FOREIGN KEY ( branch_code )
        REFERENCES branch ( branch_code )
            ON DELETE SET NULL;

ALTER TABLE book_copy
    ADD CONSTRAINT fk_bc_book_call FOREIGN KEY ( book_call_no )
        REFERENCES book_detail ( book_call_no )
            ON DELETE SET NULL;

ALTER TABLE reserve
    ADD CONSTRAINT fk_bc_id FOREIGN KEY ( bc_id,
                                          branch_code )
        REFERENCES book_copy ( bc_id,
                               branch_code )
            ON DELETE SET NULL;

ALTER TABLE reserve
    ADD CONSTRAINT fk_reserve_bor FOREIGN KEY ( bor_no )
        REFERENCES borrower ( bor_no )
            ON DELETE SET NULL;

ALTER TABLE loan
    ADD CONSTRAINT fk_loan_branchcd FOREIGN KEY ( branch_code,
                                                  bc_id )
        REFERENCES book_copy ( branch_code,
                               bc_id )
            ON DELETE SET NULL;

ALTER TABLE loan
    ADD CONSTRAINT fk_loan_bor FOREIGN KEY ( bor_no )
        REFERENCES borrower ( bor_no )
            ON DELETE SET NULL;
     
/*
1.2
Add the full set of DROP TABLE statements to your solutions script. In completing this section you must not use the CASCADE 
CONSTRAINTS clause as part of your DROP TABLE statement (you should include the PURGE clause).
 
*/

drop table reserve purge;
drop table loan purge;
drop table book_copy purge;
drop table bd_author purge;
drop table author purge;
drop table bd_subject purge;
drop table subject purge;
drop table book_detail purge;
drop table publisher purge;
drop table borrower purge;
drop table branch_fiction_non purge;
drop table branch purge;
drop table manager purge;


--Q2
/*
 2.1
MonLib has just purchased its first 3 copies of a recently released edition of a book. Readers of this book will learn about 
the subjects "Database Design" and "Database Management". 

Some of  the details of the new book are:

	      	Call Number: 005.74 C822D 2018
Title: Database Systems: Design, Implementation, and Management
	      	Publication Year: 2018
	      	Edition: 13
	      	Publisher: Cengage
	Authors: Carlos CORONEL (author_id = 1 ) and 
   Steven MORRIS  (author_id = 2)  	      	
Price: $120
	
You may make up any other reasonable data values you need to be able to add this book.

Each of the 3 MonLib branches listed below will get a single copy of this book, the book will be available for borrowing 
(ie not on counter reserve) at each branch:

		Caulfield (Ph: 8888888881)
		Glen Huntly (Ph: 8888888882)
        Carnegie (Ph: 8888888883)

Your are required to treat this add of the book details and the three copies as a single transaction.
*/

INSERT INTO book_detail (
    book_call_no,
    book_title,
    book_classification,
    book_no_pages,
    book_pub_year,
    book_edition,
    pub_id
)
    SELECT
        '005.74 C822D 2018',
        'Database Systems: Design, Implementation, and Management',
        'R',
        850,
        TO_DATE('2018','yyyy'),
        '13',
        pub_id
    FROM
        publisher p
    WHERE
        pub_name = 'Cengage';

INSERT INTO bd_subject VALUES (
    (
        SELECT
            subject_code
        FROM
            subject
        WHERE
            subject_details = 'Database Management'
    ),
    ( '005.74 C822D 2018' )
);

INSERT INTO bd_subject VALUES (
    (
        SELECT
            subject_code
        FROM
            subject
        WHERE
            subject_details = 'Database Design'
    ),
    ( '005.74 C822D 2018' )
);

INSERT INTO bd_author (
    book_call_no,
    author_id
)
    SELECT
        book_detail.book_call_no,
        author.author_id
    FROM
        book_detail,
        author
    WHERE
        book_detail.book_call_no = '005.74 C822D 2018'
        AND author.author_id = 1;


INSERT INTO bd_author (
    book_call_no,
    author_id
)
    SELECT
        book_detail.book_call_no,
        author.author_id
    FROM
        book_detail,
        author
    WHERE
        book_detail.book_call_no = '005.74 C822D 2018'
        AND author.author_id = 2;


INSERT INTO book_copy (
    branch_code,
    bc_id,
    bc_purchase_price,
    bc_reserve_flag,
    book_call_no
)
    SELECT
        branch.branch_code,
        100000,
        120.00,
        'L',
        book_detail.book_call_no
    FROM
        branch,
        book_detail
    WHERE
        branch_name = (
            SELECT
                branch_name
            FROM
                branch
            WHERE
                branch_name = 'Caulfield'
        )
        AND book_call_no = (
            SELECT
                book_call_no
            FROM
                book_detail
            WHERE
                book_call_no = '005.74 C822D 2018'
        );
UPDATE branch
SET
    branch_count_books = ( branch_count_books + 1 )
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Caulfield'
    );


INSERT INTO book_copy (
    branch_code,
    bc_id,
    bc_purchase_price,
    bc_reserve_flag,
    book_call_no
)
    SELECT
        branch.branch_code,
        100000,
        120.00,
        'L',
        book_detail.book_call_no
    FROM
        branch,
        book_detail
    WHERE
        branch_name = (
            SELECT
                branch_name
            FROM
                branch
            WHERE
                branch_name = 'Glen Huntly'
        )
        AND book_call_no = (
            SELECT
                book_call_no
            FROM
                book_detail
            WHERE
                book_call_no = '005.74 C822D 2018'
        );

UPDATE branch
SET
    branch_count_books = ( branch_count_books + 1 )
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Glen Huntly'
    ); 
        
INSERT INTO book_copy (
    branch_code,
    bc_id,
    bc_purchase_price,
    bc_reserve_flag,
    book_call_no
)
    SELECT
        branch.branch_code,
        100000,
        120.00,
        'L',
        book_detail.book_call_no
    FROM
        branch,
        book_detail
    WHERE
        branch_name = (
            SELECT
                branch_name
            FROM
                branch
            WHERE
                branch_name = 'Carnegie'
        )
        AND book_call_no = (
            SELECT
                book_call_no
            FROM
                book_detail
            WHERE
                book_call_no = '005.74 C822D 2018'
        );

UPDATE branch
SET
    branch_count_books = ( branch_count_books + 1 )
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Carnegie'
    ); 
commit;

/*
2.2
An Oracle sequence is to be implemented in the database for the subsequent insertion of records into the database for  
BORROWER table. 

Provide the CREATE 	SEQUENCE statement to create a sequence which could be used to provide primary key values for the BORROWER 
table. The sequence should start at 10 and increment by 1.
*/

CREATE SEQUENCE bor_no_seq START WITH 10 INCREMENT BY 1;

/*
2.3
Provide the DROP SEQUENCE statement for the sequence object you have created in question 2.2 above. 
*/


drop sequence bor_no_seq;


--Q3
/*
--3.1
Today is 20th September, 2018, add a new borrower in the database. Some of the details of the new borrower are:

		Name: Ada LOVELACE
		Home Branch: Caulfield (Ph: 8888888881)

You may make up any other reasonable data values you need to be able to add this borrower.

*/

INSERT INTO borrower (
    bor_no,
    bor_fname,
    bor_lname,
    bor_street,
    bor_suburb,
    bor_postcode,
    branch_code
)
    SELECT
        bor_no_seq.NEXTVAL,
        'Ada',
        'Lovelace',
        'Chapmann',
        'Richmond',
        '3021',
        branch.branch_code
    FROM
        branch
    WHERE
        branch.branch_name = 'Caulfield'
        AND branch.branch_contact_no = 8888888881;


commit;


/*
--3.2
Immediately after becoming a member, at 4PM, Ada places a reservation on a book at the Carnegie branch (Ph: 8888888883). Some 
of the details of the book that Ada  has placed a reservation on are:

		Call Number: 005.74 C822D 2018
        Title: Database Systems: Design, Implementation, and Management
		Publication Year: 2018
		Edition: 13

You may assume:
MonLib has not purchased any further copies of this book, beyond those which you inserted in Task 2.1
that nobody has become a member of the library between Ada becoming a member and this reservation.

*/

UPDATE book_copy
SET
    bc_reserve_flag = 'R'
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Carnegie'
            AND branch_contact_no = 8888888883
    );

INSERT INTO reserve ( branch_code, bc_id, reserve_date_time_placed, bor_no)
    select
        book_copy.branch_code,
        book_copy.bc_id,
        TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM'),
        borrower.bor_no
    FROM
        book_copy,
        borrower
    WHERE
        book_copy.branch_code = (
            SELECT
                branch_code
            FROM
                book_copy
            WHERE
                branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                        and 
                        BRANCH_CONTACT_NO = 8888888883
                )
        )
        AND book_copy.bc_id = (
            SELECT
                bc_id
            FROM
                book_copy
            WHERE
                book_call_no = '005.74 C822D 2018'
                AND book_copy.branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                )
        )
        AND borrower.bor_no = (
            SELECT
                bor_no
            FROM
                borrower
            WHERE
                bor_lname = 'Lovelace'
        );

commit;

/*
3.3
After 7 days from reserving the book, Ada receives a notification from the Carnegie library that the book she had placed
reservation on is available. Ada is very excited about the book being available as she wants to do very well in FIT9132 unit 
that she is currently studying at Monash University. Ada goes to the library and borrows the book at 2 PM on the same day of 
receiving the notification.

You may assume that there is no other borrower named Ada Lovelace.
*/

UPDATE book_copy
SET
    bc_reserve_flag = 'L'
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Carnegie'
            AND branch_contact_no = 8888888883
    );


INSERT INTO loan (
    branch_code,
    bc_id,
    loan_date_time,
    loan_due_date,
    loan_actual_return_date,
    bor_no
)
    SELECT
        book_copy.branch_code,
        book_copy.bc_id,
        ( TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM') - INTERVAL '2' HOUR ) + '7' day,
        ( TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM') - INTERVAL '2' HOUR ) + '7' + '28' day,
        NULL,
        borrower.bor_no
    FROM
        book_copy,
        borrower
    WHERE
        book_copy.branch_code = (
            SELECT
                branch_code
            FROM
                book_copy
            WHERE
                branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                        and 
                        BRANCH_CONTACT_NO = 8888888883
                )
        )
        AND book_copy.bc_id = (
            SELECT
                bc_id
            FROM
                book_copy
            WHERE
                book_call_no = '005.74 C822D 2018'
                AND book_copy.branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                )
        )
        AND borrower.bor_no = (
            SELECT
                bor_no
            FROM
                borrower
            WHERE
                bor_lname = 'Lovelace'
        );

UPDATE book_copy
SET
    bc_reserve_flag = 'R'
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Carnegie'
            AND branch_contact_no = 8888888883
    );
     
commit;


/*
3.4
At 2 PM on the day the book is due, Ada goes to the library and renews the book as her exam for FIT9132 is in 2 weeks.
		
You may assume that there is no other borrower named Ada Lovelace.
*/

UPDATE loan
SET
    loan_actual_return_date = loan_due_date
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
    AND bc_id = (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
    AND loan_date_time = ( TO_DATE('09202018 02:00:00 PM','mm/dd/yyyy hh:mi:ss PM') ) + '7';
    
INSERT INTO loan (
    branch_code,
    bc_id,
    loan_date_time,
    loan_due_date,
    loan_actual_return_date,
    bor_no
)
    SELECT
        book_copy.branch_code,
        book_copy.bc_id,
        ( TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM') - INTERVAL '2' HOUR ) + '7' + '28' day,
        ( TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM') - INTERVAL '2' HOUR ) + '7' + '28' + '14' day,
        NULL,
        borrower.bor_no
    FROM
        book_copy,
        borrower
    WHERE
        book_copy.branch_code = (
            SELECT
                branch_code
            FROM
                book_copy
            WHERE
                branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                )
        )
        AND book_copy.bc_id = (
            SELECT
                bc_id
            FROM
                book_copy
            WHERE
                book_call_no = '005.74 C822D 2018'
                AND book_copy.branch_code = (
                    SELECT
                        branch_code
                    FROM
                        branch
                    WHERE
                        branch_name = 'Carnegie'
                        and 
                        BRANCH_CONTACT_NO = 8888888883
                )
        )
        AND borrower.bor_no = (
            SELECT
                bor_no
            FROM
                borrower
            WHERE
                bor_lname = 'Lovelace'
        );

commit;

--Q4
/*
4.1
Record whether a book is damaged (D) or lost (L). If the book is not damaged or lost,then it  is good (G) which means, 
it can be loaned. The value cannot be left empty  for this. Change the "live" database and add this required information 
for all the  books currently in the database. You may assume that condition of all existing books will be recorded as being 
good. The information can be updated later, if need be. 
*/

ALTER TABLE book_copy ADD (
    book_condition   CHAR(1)
);

ALTER TABLE book_copy
    ADD CONSTRAINT book_condition_cky CHECK ( book_condition IN (
        'D',
        'L',
        'G'
    ) );

COMMENT ON COLUMN book_copy.book_condition IS
    'Book condition, can only be Damaged (D), Lost (L) or good (G)';

UPDATE book_copy
SET
    book_condition = 'G';

    
commit;

/*
4.2
Allow borrowers to be able to return the books they have loaned to any library branch as MonLib is getting a number of requests 
regarding this from borrowers. As part of this process MonLib wishes to record which branch a particular loan is returned to. 
Change the "live" database and add this required information for all the loans  currently in the database. For all completed 
loans, to this time, books were returned at the same branch from where those were loaned.
*/

ALTER TABLE loan ADD (
    book_return_branch   NUMERIC(2)
);

alter table loan add constraints book_return_fk foreign key (book_return_branch)
    references branch (branch_code)
    on delete set null;

COMMENT ON COLUMN loan.book_return_branch IS
    'Where the borrower is returning the book';

UPDATE loan
SET
    book_return_branch = (
        SELECT
            branch_code
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
    AND bc_id = (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    );

UPDATE loan
SET
    loan_actual_return_date = LOAN_DUE_DATE
WHERE
    loan.branch_code = (
        SELECT
            branch_code
        FROM
            book_copy
        WHERE
            branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
    AND bc_id = (
        SELECT
            bc_id
        FROM
            book_copy
        WHERE
            book_call_no = '005.74 C822D 2018'
            AND branch_code = (
                SELECT
                    branch_code
                FROM
                    branch
                WHERE
                    branch_name = 'Carnegie'
            )
    )
    AND loan_date_time = ( TO_DATE('09202018 04:00:00 PM','mm/dd/yyyy hh:mi:ss PM')- INTERVAL '2' HOUR ) + '7' + '28';

UPDATE book_copy
SET
    bc_reserve_flag = 'L'
WHERE
    branch_code = (
        SELECT
            branch_code
        FROM
            branch
        WHERE
            branch_name = 'Carnegie'
            AND branch_contact_no = 8888888883
    );

commit;

/*
4.3
Some of the MonLib branches have become very large and it is difficult for a single manager to look after all aspects of the 
branch. For this reason MonLib are intending to appoint two managers for the larger branches starting in the new year - one 
manager for the Fiction collection and another for the Non-Fiction collection. The branches which continue to have one manager 
will ask this manager to manage the branches Full collection. The number of branches which will require two managers is quite 
small (around 10% of the total MonLib branches). Change the "live" database to allow monLib the option of appointing two 
managers to a branch and track and also record, for all managers, which collection/s they are managing. 

In the new year, since the Carnegie branch (Ph: 8888888883) has a huge collection of books in comparison to the Caulfield and 
Glen Huntly branches, Robert (Manager id: 1) who is currently managing the Caulfield branch (Ph: 8888888881) has been asked to 
manage the Fiction collection of the Carnegie branch, as well as the full collection at the Caulfield branch. Thabie 
(Manager id: 2) who is currently managing the Glen Huntly branch (Ph: 8888888882) has been asked to manage the Non-Fiction 
collection of Carnegie branch, as well as the full collection at the Glen Huntly branch. Write the code to implement these 
changes.
*/

CREATE TABLE branch_fiction_non (
    branch_code   NUMERIC(2) NOT NULL,
    man_id        NUMERIC(2) NOT NULL,
    fiction_non   VARCHAR2(11) NOT NULL,
    CONSTRAINT pk_fiction PRIMARY KEY ( branch_code,
                                        man_id )
);

ALTER TABLE branch_fiction_non ADD constraints fk_branch_code foreign key (branch_code)
        references branch (branch_code)
        on delete set null;
        
alter table branch_fiction_non add constraints fk_man_id FOREIGN KEY(man_id)
    REFERENCES manager(man_id)
        ON
        DELETE set NULL;

ALTER TABLE branch_fiction_non
    ADD CONSTRAINT fiction_cky CHECK ( fiction_non IN (
        'Fiction',
        'Non_fiction',
        'Full'
    ) );

COMMENT ON COLUMN branch_fiction_non.fiction_non IS
    'Either the manager works in Fiction, Non_fiction or both of them (full)';

INSERT INTO branch_fiction_non (
    branch_code,
    man_id,
    fiction_non
)
    SELECT
        branch_code,
        (
            SELECT
                man_id
            FROM
                manager
            WHERE
                man_fname = 'Robert'
        ),
        'Full'
    FROM
        branch
    WHERE
        branch_name = 'Caulfield';

INSERT INTO branch_fiction_non (
    branch_code,
    man_id,
    fiction_non
)
    SELECT
        branch_code,
        (
            SELECT
                man_id
            FROM
                manager
            WHERE
                man_fname = 'Thabie'
        ),
        'Full'
    FROM
        branch
    WHERE
        branch_name = 'Glen Huntly';

INSERT INTO branch_fiction_non (
    branch_code,
    man_id,
    fiction_non
)
    SELECT
        branch_code,
        (
            SELECT
                man_id
            FROM
                manager
            WHERE
                man_fname = 'Robert'
        ),
        'Fiction'
    FROM
        branch
    WHERE
        branch_name = 'Carnegie';

INSERT INTO branch_fiction_non (
    branch_code,
    man_id,
    fiction_non
)
    SELECT
        branch_code,
        (
            SELECT
                man_id
            FROM
                manager
            WHERE
                man_fname = 'Thabie'
        ),
        'Non_fiction'
    FROM
        branch
    WHERE
        branch_name = 'Carnegie';

COMMIT;