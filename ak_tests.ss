;;; And now the tests from the old alphamk.scm

(load "alphaK.ss")
(import (alphaK))

(define-syntax testit
  (syntax-rules ()
    ((_ exp val)
     (begin
       (display "testing: ")
       (tester 'exp exp val)))))

(define tester
  (lambda (exp v val)
    (cond
      ((equal? v val) (write 'okay) (newline))
      (else
        (error 'testit
               (format "exp: ~s\nexpected: ~s\ncomputed: ~s" exp val v))))))

(testit
 (run 1 (q) (fresh (x y z) (== x z) (== 3 y)))
 '(_.0))

(testit
 (run 1 (q) (fresh (x y) (== x q) (== 3 y)))
 '(_.0))

(testit
  (run 1 (y)
    (fresh (x z) 
      (== x z)
      (== 3 y)))
 '(3))

(testit
 (run 1 (q)
  (fresh (x z)
    (== x z)
    (== 3 z)
    (== q x)))
 '(3))

(testit
  (run 1 (y)
   (fresh (x y)
     (== 4 x)
     (== x y))
   (== 3 y))
  '(3))

(testit
  (run 1 (x) (== 4 3))
  '())

(testit
 (run 2 (q)
  (fresh (x y z)
    (conde
      ((== `(,x ,y ,z ,x) q))
      ((== `(,z ,y ,x ,z) q)))))
 '((_.0 _.1 _.2 _.0)
   (_.0 _.1 _.2 _.0)))

(testit
 (run 5 (q)
  (let loop ()
    (conde
      ((== #f q))
      ((== #t q))
      ((loop)))))
 '(#f #t #f #t #f))

(define anyo 
  (lambda (g)
    (conde
      (g)
      ((anyo g)))))

(testit
 (run 5 (q)
  (conde
    ((anyo (== #f q)))
    ((== #t q))))
 '(#t #f #f #f #f))

(testit
 (run 10 (q)
   (anyo 
    (conde
      ((== 1 q))
      ((== 2 q))
      ((== 3 q)))))
 '(1 2 3 1 2 3 1 2 3 1))

(testit
 (run 3 (q)
  (let ((nevero (anyo (== #f #t))))
    (conde
      ((== 1 q))
      (nevero)
      ((conde
         ((== 2 q))
         (nevero)
         ((== 3 q)))))))
 '(1 2 3))

(testit
  (run* (q) (fresh-nom (a) (== a a)))
  '(_.0))

(testit
 (run* (q) (fresh-nom (a) (== a 5)))
 '())

(testit
  (run* (q) (fresh-nom (a b) (== a b)))
  '())

(testit
  (run* (q) (fresh-nom (a b) (== b q)))
  '(a.0))

(testit
 (run* (q)
  (fresh (x y z)
    (fresh-nom (a)
      (== x a)
      (fresh-nom (a b)
        (== y a)
        (== `(,x ,y ,z ,a ,b) q)))))
  '((a.0 a.1 _.0 a.1 a.2)))

(testit
 (run* (q)
  (fresh-nom (a b)
    (== (tie a `(foo ,a 3 ,b)) q)))
 '((tie a.0 (foo a.0 3 a.1))))

(testit
  (run* (q) (fresh-nom (a b) (== `(foo ,a ,a) `(foo ,b ,b))))
  '())

(testit
  (run* (q) (fresh-nom (a b) (== (tie a a) (tie b b))))
  '(_.0))

(testit
 (run* (q) (fresh-nom (a b) (== (tie a q) (tie b b))))
 '(a.0))

(testit
 (run* (q)
  (fresh (t u)
    (fresh-nom (a b c d)
      (== `(lam ,(tie a `(lam ,(tie b `(var ,a))))) t)
      (== `(lam ,(tie c `(lam ,(tie d `(var ,c))))) u)
      (== t u))))
 '(_.0))

(testit
 (run* (q)
  (fresh (t u)
    (fresh-nom (a b c d)
      (== `(lam ,(tie a `(lam ,(tie b `(var ,a))))) t)
      (== `(lam ,(tie c `(lam ,(tie d `(var ,d))))) u)
      (== t u))))
 '())

(testit
 (run* (q) (fresh-nom (a) (hash a a)))
 '())

(testit
 (run* (q) (fresh-nom (a) (hash a 5)))
 '(_.0))

(testit
 (run* (q) (fresh-nom (a) (hash a (tie a a))))
 '(_.0))

(testit
 (run* (q) (fresh-nom (a b) (hash a (tie b a))))
 '())

(testit
 (run* (k)
  (fresh (t)
    (fresh-nom (a)
      (hash a k) 
      (== `(5 ,(tie a a) ,t) k))))
 '(((5 (tie a.0 a.0) _.0) : ((a.0 _.0)))))

(testit
 (run* (k)
  (fresh (t)
    (fresh-nom (a)
      (hash a k) 
      (== `(5 ,(tie a a) ,t) k)
      (== `(foo ,a 7) t))))
 '())

(testit
 (run* (k)
  (fresh (t)
    (fresh-nom (a b)
      (== (tie a (tie b t)) k) 
      (hash a t)
      (== `((,a ,b) ,b) t))))
 '())

(testit
 (run* (k)
  (fresh (t)
    (fresh-nom (a b)
      (== (tie a (tie b t)) k) 
      (hash a t)
      (== `(,b ,(tie a `(,a (,b ,b)))) t))))
 '((tie a.0 (tie a.1 (a.1 (tie a.0 (a.0 (a.1 a.1))))))))

(testit
 (run* (q)
  (fresh (k1 k2 t u)
    (fresh-nom (a b c d)
      (== (tie a (tie b t)) k1) 
      (hash a t)
      (== (tie c (tie d u)) k2)
      (hash c u)
      (== k1 k2)
      (== `(,k1 ,k2) q))))
 '((((tie a.0 (tie a.1 (sus ((a.1 . a.2) (a.0 . a.3)) _.0)))
     (tie a.3 (tie a.2 _.0)))
    :
    ((a.0 _.0) (a.3 _.0) (a.1 _.0)))))

(testit
 (run* (q)
  (fresh (k1 k2 t u)
    (fresh-nom (a b c d)
      (== (tie a (tie b t)) k1) 
      (hash a t)
      (== `(,b ,b) t)
      (== (tie c (tie d u)) k2)
      (hash c u)
      (== `(,d ,d) u)
      (== k1 k2)
      (== `(,k1 ,k2) q))))
 '(((tie a.0 (tie a.1 (a.1 a.1)))
    (tie a.2 (tie a.3 (a.3 a.3))))))

(testit
 (run* (q)
   (fresh-nom (a b)
     (fresh (x y)
       (== (tie a (tie a x)) (tie a (tie b y)))
       (== `(,x ,y) q))))
 '((((sus ((a.0 . a.1)) _.0) _.0) : ((a.0 _.0)))))

(testit 
 (run* (q)
  (fresh-nom (a b)
    (fresh (x y)
      (conde
        ((== (tie a (tie b `(,x ,b))) (tie b (tie a `(,a ,x)))))
        ((== (tie a (tie b `(,y ,b))) (tie b (tie a `(,a ,x)))))
        ((== (tie a (tie b `(,b ,y))) (tie b (tie a `(,a ,x)))))
        ((== (tie a (tie b `(,b ,y))) (tie a (tie a `(,a ,x))))))
      (== `(,x ,y) q))))
 '((a.0 a.1)
   (_.0 (sus ((a.0 . a.1)) _.0))
   ((_.0 (sus ((a.0 . a.1)) _.0)) : ((a.0 _.0)))))

(define substo  
  (lambda (e new a out)
    (conde
      ((== `(var ,a) e) (== new out))
      ((fresh (y)
         (== `(var ,y) e)
         (== `(var ,y) out)
         (hash a y)))
      ((fresh (rator ratorres rand randres)
         (== `(app ,rator ,rand) e)
         (== `(app ,ratorres ,randres) out)
         (substo rator new a ratorres)
         (substo rand new a randres)))
      ((fresh (body bodyres)
         (fresh-nom (c)
           (== `(lam ,(tie c body)) e)
           (== `(lam ,(tie c bodyres)) out)
           (hash c a)
           (hash c new)
           (substo body new a bodyres)))))))

(testit
 (run* (x)
  (fresh-nom (a b)
    (substo `(lam ,(tie a `(var ,b))) `(var ,a) b x)))
 '((lam (tie a.0 (var a.1)))))

(testit
 (run* (q)
  (fresh-nom (a b)
    (substo
      `(lam ,(tie a `(app (var ,a) (var ,b)))) b a q)))
 '((lam (tie a.0 (app (var a.0) (var a.1))))))


(define typo
  (lambda (g e te)
    (conde
      ((fresh (x)
         (== `(var ,x) e)
         (lookupo x te g)))
      ((fresh (rator trator rand trand)
         (== `(app ,rator ,rand) e)
         (== `(-> ,trand ,te) trator)
         (typo g rator trator)
         (typo g rand trand)))
      ((fresh (e^ te^ trand g^)
         (fresh-nom (b)
           (== `(lam ,(tie b e^)) e)
           (== `(-> ,trand ,te^) te)
           (hash b g)
           (== `((,b . ,trand) . ,g) g^)
           (typo g^ e^ te^))))
      ((fresh (rator t-val)
         (== `(C ,rator) e)
         (typo g rator `(-> (-> ,te ,t-val) ,t-val)))))))

(define !-c
  (lambda (gamma exp type)
    (fresh (m a b)
      (== `(c ,m) exp)
      (== a type)
      (!- gamma m `(-> (-> ,a ,b) ,b)))))

(define lookupo
  (lambda (x tx g)
    (fresh (a d)
      (== `(,a . ,d) g)
      (conde
        ((== `(,x . ,tx) a))
        ((fresh (x^ tx^)
           (== `(,x^ . ,tx^) a)
           (hash x x^)
           (lookupo x tx d)))))))

(testit
 (run* (q)
  (fresh-nom (c d)
    (typo '() `(lam ,(tie c `(lam ,(tie d `(var ,c))))) q)))
 '((-> _.0 (-> _.1 _.0))))

(testit
 (run* (q)
  (fresh-nom (c d)
    (typo '() `(lam ,(tie c `(lam ,(tie d `(var ,c))))) q)))
 '((-> _.0 (-> _.1 _.0))))

;; WEB 5 Feb 2012
;; diverges?
;; not sure what is up with this one
'(testit
(run* (q)
  (fresh-nom (c)
    (typo '() `(lam ,(tie c `(app (var ,c) (var ,c)))) q)))
 '())

(testit
 (run 5 (q) (typo '() q '(-> int int)))
 '((lam (tie a.0 (var a.0)))
   (C (lam (tie a.0 (var a.0))))
   (app (lam (tie a.0 (var a.0))) (lam (tie a.1 (var a.1))))
   (lam (tie a.0 (C (lam (tie a.1 (var a.1))))))
   (lam (tie a.0 (app (lam (tie a.1 (var a.1))) (var a.0))))))

(testit
 (run* (q)
  (fresh (x y z)
    (fresh-nom (a)      
      (hash a x)
      (== `(,y ,z) x)
      (== `(,x ,a) q))))
 '((((_.0 _.1) a.0) : ((a.0 _.0 _.1)))))