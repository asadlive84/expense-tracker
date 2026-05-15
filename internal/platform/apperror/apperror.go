package apperror

import (
	"encoding/json"
	"net/http"
)

type Code string

const (
	CodeInvalidCredentials Code = "invalid_credentials"
	CodeValidationError    Code = "validation_error"
	CodeNotFound           Code = "not_found"
	CodeForbidden          Code = "forbidden"
	CodeConflict           Code = "conflict"
	CodeInternal           Code = "internal_error"
)

type AppError struct {
	HTTPStatus int
	Code       Code
	Message    string
	Fields     map[string]string
}

func (e *AppError) Error() string { return string(e.Code) + ": " + e.Message }

func New(status int, code Code, message string) *AppError {
	return &AppError{HTTPStatus: status, Code: code, Message: message}
}

func NotFound(message string) *AppError {
	return New(http.StatusNotFound, CodeNotFound, message)
}

func Forbidden(message string) *AppError {
	return New(http.StatusForbidden, CodeForbidden, message)
}

func Conflict(message string) *AppError {
	return New(http.StatusConflict, CodeConflict, message)
}

func Internal(message string) *AppError {
	return New(http.StatusInternalServerError, CodeInternal, message)
}

func ValidationError(message string, fields map[string]string) *AppError {
	return &AppError{
		HTTPStatus: http.StatusBadRequest,
		Code:       CodeValidationError,
		Message:    message,
		Fields:     fields,
	}
}

func InvalidCredentials() *AppError {
	return New(http.StatusUnauthorized, CodeInvalidCredentials, "invalid email or password")
}

type errorBody struct {
	Code    Code              `json:"code"`
	Message string            `json:"message"`
	Fields  map[string]string `json:"fields,omitempty"`
}

type errorEnvelope struct {
	Error errorBody `json:"error"`
}

func Render(w http.ResponseWriter, err *AppError) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(err.HTTPStatus)
	_ = json.NewEncoder(w).Encode(errorEnvelope{
		Error: errorBody{
			Code:    err.Code,
			Message: err.Message,
			Fields:  err.Fields,
		},
	})
}
