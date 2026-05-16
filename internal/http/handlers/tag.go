package handlers

import (
	"net/http"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/tag"
)

type TagHandler struct {
	svc *tag.Service
}

func NewTagHandler(svc *tag.Service) *TagHandler {
	return &TagHandler{svc: svc}
}

func (h *TagHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	items, err := h.svc.List(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *TagHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	var in tag.CreateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(in); err != nil {
		handleError(w, err)
		return
	}
	t, err := h.svc.Create(r.Context(), userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, t)
}

func (h *TagHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	id, err := parseUUID(r, "id")
	if err != nil {
		handleError(w, err)
		return
	}
	var in tag.UpdateInput
	if err := decodeJSON(r, &in); err != nil {
		handleError(w, err)
		return
	}
	t, err := h.svc.Update(r.Context(), id, userID, in)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, t)
}

func (h *TagHandler) Delete(w http.ResponseWriter, r *http.Request) {
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
