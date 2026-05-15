package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/asad/expense-tracker/internal/platform/apperror"
	"github.com/go-chi/chi/v5"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
)

var validate = validator.New()

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func decodeJSON(r *http.Request, dst any) error {
	if err := json.NewDecoder(r.Body).Decode(dst); err != nil {
		return apperror.New(http.StatusBadRequest, apperror.CodeValidationError, "invalid JSON: "+err.Error())
	}
	return nil
}

func validateStruct(v any) error {
	if err := validate.Struct(v); err != nil {
		var ve validator.ValidationErrors
		if errors.As(err, &ve) {
			fields := make(map[string]string, len(ve))
			for _, fe := range ve {
				fields[fe.Field()] = fe.Tag()
			}
			return apperror.ValidationError("validation failed", fields)
		}
		return apperror.ValidationError(err.Error(), nil)
	}
	return nil
}

func handleError(w http.ResponseWriter, err error) {
	var ae *apperror.AppError
	if errors.As(err, &ae) {
		apperror.Render(w, ae)
		return
	}
	apperror.Render(w, apperror.Internal(err.Error()))
}

func parseUUID(r *http.Request, param string) (uuid.UUID, error) {
	id, err := uuid.Parse(chi.URLParam(r, param))
	if err != nil {
		return uuid.Nil, apperror.New(http.StatusBadRequest, apperror.CodeValidationError, "invalid "+param+": must be a UUID")
	}
	return id, nil
}
