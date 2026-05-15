package handlers

import (
	"net/http"
	"time"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/reminder"
)

type ReminderHandler struct {
	svc *reminder.Service
}

func NewReminderHandler(svc *reminder.Service) *ReminderHandler {
	return &ReminderHandler{svc: svc}
}

func (h *ReminderHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var dueBefore *time.Time
	if v := r.URL.Query().Get("due_before"); v != "" {
		if t, err := time.Parse(time.RFC3339, v); err == nil {
			dueBefore = &t
		} else if t, err := time.Parse("2006-01-02", v); err == nil {
			dueBefore = &t
		}
	}
	items, err := h.svc.List(r.Context(), userID, dueBefore)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *ReminderHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var in reminder.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	rem, err := h.svc.Create(r.Context(), userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, rem)
}

func (h *ReminderHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in reminder.UpdateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	rem, err := h.svc.Update(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, rem)
}

func (h *ReminderHandler) Pay(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in reminder.PayInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	result, err := h.svc.Pay(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}

func (h *ReminderHandler) Skip(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	rem, err := h.svc.Skip(r.Context(), id, userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, rem)
}
