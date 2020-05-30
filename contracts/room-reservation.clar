
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


;; This function is to get the status of a room if its available for rent
;; Argument roomNo is set to match if the specific room is availabe
(define-public (get-room-info (roomNo int))
   (if (is-eq roomNumber roomNo )
      (ok (var-get roomAvailable))
      (err false)
   )
)


;; This functions purpose is to set the room price as downpayment and balance
;; and be later use on to get how much is needed to pay
;; Argument dp and bal is set to change the value of the variable downpayment and balance
(define-public (set-room-price (dp int) (bal int))
   (begin
      (var-set downpayment (to-uint dp))
      (var-set balance (to-uint bal))
      (ok true)
   )
)


;; This functions purpose is to check if the customers stack is greater than the value
;; of the downpayment to be able to pay the right amount of stack
;; Argument stacks is defined to be use to check if the stacks is greater than the downpayment
(define-public (check-downpayment (stacks int))
   (if (> (to-uint stacks) (var-get downpayment))
      (begin
         (var-set downpaymentOk true)
         (ok (var-get downpaymentOk))
      )
      (err false)
   )
)

;; This functions purpose is to check the room availability
;; before paying the downpayment to make sure that its still available for rent
;; The argument roomNo is defined to check for the specific room
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

;; This functions purpose is to get the downpayment needed for the rent
;; and used the variable needed for paying the downpayment
(define-public (get-downpayment (roomNo int))
   (if (is-eq roomNumber roomNo)
      (ok (var-get downpayment))
      (err false)
   )
)

;; This functions purpose is to transfer the payment to the owner
;; The argument payment is defined to be used to declare how much is stx is needed to be transferred
(define-private (deposit-payment (payment uint))
  (begin
   (stx-transfer? payment tx-sender owner)
  )
)

;; This functions purpose is to initiate the payment of the needed downpayment
;; The argument payment is defined to be used to declare how much is stx is needed to be transferred
;; while roomNo is used to look for the specific roomNo
;; The function checks first if the roomNo matches the roomNo needed to be paid
;; then checks if room is available Once all passed the requirements the variable isDownpayment is set to true
;; as a proof of payment and proceeds running the function deposit-payment
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

;; This functions purpose is to get the remaining balance needed for the rent
;; and used the variable needed for paying the remaining balance
(define-public (get-balance (roomNo int))
   (if (is-eq roomNumber roomNo)
      (ok (var-get balance))
      (err false)
   )
)

;; This functions purpose is to initiate the payment of the needed balance
;; The argument payment is defined to be used to declare how much is stx is needed to be transferred
;; while roomNo is used to look for the specific roomNo
;; The function checks first if the roomNo matches the roomNo needed to be paid
;; then checks if room is available Once all passed the requirements the variable isBalancePaid is set to true
;; as a proof of payment and proceeds running the function deposit-payment
(define-public (deposit-balance (payment uint) (roomNo uint))
   (begin
      (if (is-eq (to-uint roomNumber) roomNo)
         (if (is-eq customer tx-sender)
            (begin
               (var-set isBalancePaid true)
               (ok (deposit-payment payment))
            )
            (err false)
         )
         (err false)
      )
   )
)






