;; Vehicle Designs Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var design-counter uint u0)
(define-map vehicle-designs uint {
    name: (string-ascii 100),
    dimensions: uint,
    capacity: uint,
    speed: uint,
    safety-rating: uint,
    creator: principal
})

;; Public Functions
(define-public (create-vehicle-design (name (string-ascii 100)) (dimensions uint) (capacity uint) (speed uint) (safety-rating uint))
    (let
        (
            (design-id (+ (var-get design-counter) u1))
        )
        (asserts! (and (>= dimensions u3) (<= dimensions u10)) err-invalid-parameters)
        (asserts! (> capacity u0) err-invalid-parameters)
        (asserts! (> speed u0) err-invalid-parameters)
        (asserts! (and (>= safety-rating u1) (<= safety-rating u10)) err-invalid-parameters)
        (map-set vehicle-designs design-id {
            name: name,
            dimensions: dimensions,
            capacity: capacity,
            speed: speed,
            safety-rating: safety-rating,
            creator: tx-sender
        })
        (var-set design-counter design-id)
        (ok design-id)
    )
)

(define-public (update-vehicle-design (design-id uint) (capacity uint) (speed uint) (safety-rating uint))
    (let
        (
            (design (unwrap! (map-get? vehicle-designs design-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator design)) err-not-authorized)
        (asserts! (> capacity u0) err-invalid-parameters)
        (asserts! (> speed u0) err-invalid-parameters)
        (asserts! (and (>= safety-rating u1) (<= safety-rating u10)) err-invalid-parameters)
        (map-set vehicle-designs design-id
            (merge design {
                capacity: capacity,
                speed: speed,
                safety-rating: safety-rating
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-vehicle-design (design-id uint))
    (map-get? vehicle-designs design-id)
)

(define-read-only (get-design-count)
    (var-get design-counter)
)

