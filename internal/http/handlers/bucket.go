package handlers

import (
	"net/http"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/bucket"
)

type BucketHandler struct {
	svc *bucket.Service
}

func NewBucketHandler(svc *bucket.Service) *BucketHandler {
	return &BucketHandler{svc: svc}
}

func (h *BucketHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	items, err := h.svc.List(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *BucketHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var in bucket.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	b, err := h.svc.Create(r.Context(), userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, b)
}

func (h *BucketHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in bucket.UpdateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	b, err := h.svc.Update(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, b)
}
