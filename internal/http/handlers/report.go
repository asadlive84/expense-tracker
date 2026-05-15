package handlers

import (
	"net/http"
	"time"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/domain/report"
	"github.com/asad/expense-tracker/internal/platform/apperror"
)

type ReportHandler struct {
	svc *report.Service
}

func NewReportHandler(svc *report.Service) *ReportHandler {
	return &ReportHandler{svc: svc}
}

func (h *ReportHandler) BucketBalances(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	result, err := h.svc.BucketBalances(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": result})
}

func (h *ReportHandler) PersonBalances(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	result, err := h.svc.PersonBalances(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": result})
}

func (h *ReportHandler) TagTotals(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	q := r.URL.Query()

	fromStr := q.Get("from")
	toStr := q.Get("to")
	if fromStr == "" || toStr == "" {
		apperror.Render(w, apperror.New(http.StatusBadRequest, apperror.CodeValidationError, "from and to query params required"))
		return
	}
	from, err := time.Parse("2006-01-02", fromStr)
	if err != nil {
		apperror.Render(w, apperror.New(http.StatusBadRequest, apperror.CodeValidationError, "invalid from date, use YYYY-MM-DD"))
		return
	}
	to, err := time.Parse("2006-01-02", toStr)
	if err != nil {
		apperror.Render(w, apperror.New(http.StatusBadRequest, apperror.CodeValidationError, "invalid to date, use YYYY-MM-DD"))
		return
	}
	to = to.Add(24*time.Hour - time.Second)

	result, err := h.svc.TagTotals(r.Context(), userID, from.UTC(), to.UTC())
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": result})
}

func (h *ReportHandler) Summary(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	month := r.URL.Query().Get("month")
	if month == "" {
		month = time.Now().UTC().Format("2006-01")
	}
	result, err := h.svc.Summary(r.Context(), userID, month)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, result)
}
