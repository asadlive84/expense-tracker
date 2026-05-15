package handlers

import (
	"net/http"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/person"
)

type PersonHandler struct {
	svc *person.Service
}

func NewPersonHandler(svc *person.Service) *PersonHandler {
	return &PersonHandler{svc: svc}
}

func (h *PersonHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	items, err := h.svc.List(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *PersonHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var in person.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	p, err := h.svc.Create(r.Context(), userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, p)
}

func (h *PersonHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in person.UpdateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	p, err := h.svc.Update(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, p)
}
