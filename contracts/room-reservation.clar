
(define-data-var downpayment uint u0)
(define-data-var balance uint u0)

(define-data-var downpaymentOk bool false)
(define-data-var balanceOk bool false)
(define-data-var isDownpaymentPaid bool false)
(define-data-var isBalancePaid bool false)
(define-data-var roomAvailable bool true)
(define-data-var roomPrice int 0)

(define-constant roomNumber 101)

(define-constant customer 'ST1M1ZW33KV9MPFRW3DYNVYMVR5PSDMZ0YSM91K93)
(define-constant owner 'ST2WWE6EZC1RWD82SPH7FWFF9SASA3RWCD3ZQNPQW)


(define-public (set-room-price (dp int) (bal int))
   (begin
      (var-set downpayment (to-uint dp))
      (var-set balance (to-uint bal))
      (ok true)))

(define-public (check-room-availability (roomNo int))
   (begin
      (if (is-eq roomNumber roomNo)
         (if (var-get roomAvailable)
            (ok true)
            (err false)
         )
         (err false)
      )
   )
)

(define-private (deposit-payment (payment uint))
  (begin
   (stx-transfer? payment tx-sender owner)
  )
)

(define-public (deposit-downpayment (payment uint) (roomNo uint))
   (begin
      (if (is-eq (to-uint roomNumber) roomNo)
         (if (var-get roomAvailable)
            (begin
               (var-set isDownpaymentPaid true)
               (ok (deposit-payment payment))
            )
            (err false)
         )
         (err false)
      )
   )
)


(define-public (deposit-balance (payment uint) (roomNo uint))
   (begin
      (if (is-eq (to-uint roomNumber) roomNo)
         (if (is-eq customer tx-sender)
            (begin
               (var-set isDownpaymentPaid true)
               (ok (deposit-payment payment))
            )
            (err false)
         )
         (err false)
      )
   )
)

(define-public (check-downpayment (stacks int))
   (if (> (to-uint stacks) (var-get downpayment))
      (begin
         (var-set downpaymentOk true)
         (ok (var-get downpaymentOk))
      )
      (err false)
   )
)

(define-public (get-room-info (roomNo int))
   (if (is-eq roomNumber roomNo )
      (ok (var-get roomAvailable))
      (err false)
   )
)

(define-private (get-user)
  (ok customer)
)

(define-private (get-balance)
  (ok (var-get balance))
)

(define-private (get-downpayment)
  (ok (var-get downpayment))
)



