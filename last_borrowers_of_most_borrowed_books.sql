SELECT books.book_id, title, last_borrower, loan_count
FROM books

RIGHT JOIN (
SELECT book_id, loan_count -- books with max loan count
FROM (
  SELECT book_id, COUNT(book_id) AS loan_count
  FROM loans
  GROUP BY book_id
  HAVING COUNT(book_id) = (SELECT MAX(x) FROM (SELECT book_id, COUNT(book_id) x FROM loans GROUP BY book_id ) as m ) 
) AS c
) AS books_with_max_loan_count
ON books.book_id = books_with_max_loan_count.book_id

LEFT JOIN (
SELECT book_id, last_borrower --books and last borrower
FROM(
  SELECT book_id, return_date, borrower_name AS last_borrower,
  RANK() OVER (PARTITION BY book_id ORDER BY COALESCE(return_date, '12/31/2099') DESC) RankOrder --Null = book is borrowed
  FROM loans
) r WHERE RankOrder = 1
) AS books_and_last_borrower
ON books_with_max_loan_count.book_id = books_and_last_borrower.book_id --join criteria

ORDER BY book_id 
