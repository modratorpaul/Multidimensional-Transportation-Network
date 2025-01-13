;; Safety Protocols Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var protocol-counter uint u0)
(define-map safety-protocols uint {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    dimensions: uint,
    severity: uint,
    creator: principal
})

;; Public Functions
(define-public (create-safety-protocol (name (string-ascii 100)) (description (string-utf8 1000)) (dimensions uint) (severity uint))
    (let
        (
            (protocol-id (+ (var-get protocol-counter) u1))
        )
        (asserts! (and (>= dimensions u3) (<= dimensions u10)) err-invalid-parameters)
        (asserts! (and (>= severity u1) (<= severity u10)) err-invalid-parameters)
        (map-set safety-protocols protocol-id {
            name: name,
            description: description,
            dimensions: dimensions,
            severity: severity,
            creator: tx-sender
        })
        (var-set protocol-counter protocol-id)
        (ok protocol-id)
    )
)

(define-public (update-protocol-severity (protocol-id uint) (new-severity uint))
    (let
        (
            (protocol (unwrap! (map-get? safety-protocols protocol-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get creator protocol)) err-not-authorized)
        (asserts! (and (>= new-severity u1) (<= new-severity u10)) err-invalid-parameters)
        (map-set safety-protocols protocol-id
            (merge protocol {
                severity: new-severity
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-safety-protocol (protocol-id uint))
    (map-get? safety-protocols protocol-id)
)

(define-read-only (get-protocol-count)
    (var-get protocol-counter)
)

