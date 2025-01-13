;; Multidimensional Routes Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var route-counter uint u0)
(define-map routes uint {
    name: (string-ascii 100),
    start-coordinates: (list 10 int),
    end-coordinates: (list 10 int),
    dimensions: uint,
    difficulty: uint,
    creator: principal
})

;; Public Functions
(define-public (create-route (name (string-ascii 100)) (start-coordinates (list 10 int)) (end-coordinates (list 10 int)) (dimensions uint) (difficulty uint))
    (let
        (
            (route-id (+ (var-get route-counter) u1))
        )
        (asserts! (and (>= dimensions u3) (<= dimensions u10)) err-invalid-parameters)
        (asserts! (and (>= difficulty u1) (<= difficulty u10)) err-invalid-parameters)
        (map-set routes route-id {
            name: name,
            start-coordinates: start-coordinates,
            end-coordinates: end-coordinates,
            dimensions: dimensions,
            difficulty: difficulty,
            creator: tx-sender
        })
        (var-set route-counter route-id)
        (ok route-id)
    )
)

(define-public (update-route-difficulty (route-id uint) (new-difficulty uint))
    (let
        (
            (route (unwrap! (map-get? routes route-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator route)) err-not-authorized)
        (asserts! (and (>= new-difficulty u1) (<= new-difficulty u10)) err-invalid-parameters)
        (map-set routes route-id
            (merge route {
                difficulty: new-difficulty
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-route (route-id uint))
    (map-get? routes route-id)
)

(define-read-only (get-route-count)
    (var-get route-counter)
)

