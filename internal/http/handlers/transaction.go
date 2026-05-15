package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/transaction"
	"github.com/google/uuid"
)

type TransactionHandler struct {
	svc *transaction.Service
}

func NewTransactionHandler(svc *transaction.Service) *TransactionHandler {
	return &TransactionHandler{svc: svc}
}

func (h *TransactionHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	q := r.URL.Query()

	filter := transaction.ListFilter{Limit: 50}

	if v := q.Get("type"); v != "" {
		filter.Type = v
	}
	if v := q.Get("bucket_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.BucketID = id
		}
	}
	if v := q.Get("person_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.PersonID = id
		}
	}
	if v := q.Get("tag_id"); v != "" {
		if id, err := uuid.Parse(v); err == nil {
			filter.TagID = id
		}
	}
	if v := q.Get("from"); v != "" {
		if t, err := time.Parse("2006-01-02", v); err == nil {
			filter.From = t.UTC()
		}
	}
	if v := q.Get("to"); v != "" {
		if t, err := time.Parse("2006-01-02", v); err == nil {
			filter.To = t.Add(24*time.Hour - time.Second).UTC()
		}
	}
	if v := q.Get("limit"); v != "" {
		if n, err := strconv.ParseInt(v, 10, 32); err == nil {
			filter.Limit = int32(n)
		}
	}
	if v := q.Get("cursor"); v != "" {
		cursorTime, cursorID, err := transaction.DecodeCursor(v)
		if err == nil {
			filter.CursorTime = cursorTime
			filter.CursorID = cursorID
		}
	}

	result, err := h.svc.List(r.Context(), userID, filter)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *TransactionHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var in transaction.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	tx, err := h.svc.Create(r.Context(), userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, tx)
}

func (h *TransactionHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in transaction.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	tx, err := h.svc.Update(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, tx)
}

func (h *TransactionHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	if err := h.svc.Delete(r.Context(), id, userID); err != nil {
		handleError(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
