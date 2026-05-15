package handlers

import (
	"errors"
	"net/http"

	"github.com/asad/expense-tracker/internal/auth"
	sqlcdb "github.com/asad/expense-tracker/internal/db/sqlc"
	"github.com/asad/expense-tracker/internal/platform/apperror"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type AuthHandler struct {
	pool      *pgxpool.Pool
	jwtSecret string
}

func NewAuthHandler(pool *pgxpool.Pool, jwtSecret string) *AuthHandler {
	return &AuthHandler{pool: pool, jwtSecret: jwtSecret}
}

// ── Login ────────────────────────────────────────────────────────────────────

type loginRequest struct {
	Email    string `json:"email"    validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := decodeJSON(r, &req); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(req); err != nil {
		handleError(w, err)
		return
	}

	user, err := sqlcdb.New(h.pool).GetUserByEmail(r.Context(), req.Email)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			apperror.Render(w, apperror.InvalidCredentials())
			return
		}
		handleError(w, err)
		return
	}

	if err := auth.VerifyPassword(user.PasswordHash, req.Password); err != nil {
		apperror.Render(w, apperror.InvalidCredentials())
		return
	}

	token, exp, err := auth.SignToken(user.ID, h.jwtSecret)
	if err != nil {
		handleError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"token":      token,
		"expires_at": exp,
		"user_id":    user.ID,
		"name":       user.Name,
		"phone":      user.Phone,
		"email":      user.Email,
	})
}

// ── Register ─────────────────────────────────────────────────────────────────

type registerRequest struct {
	Email    string  `json:"email"    validate:"required,email"`
	Password string  `json:"password" validate:"required,min=8"`
	Name     *string `json:"name"`
	Phone    *string `json:"phone"`
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req registerRequest
	if err := decodeJSON(r, &req); err != nil {
		handleError(w, err)
		return
	}
	if err := validateStruct(req); err != nil {
		handleError(w, err)
		return
	}

	ctx := r.Context()
	q := sqlcdb.New(h.pool)

	if _, err := q.GetUserByEmail(ctx, req.Email); err == nil {
		apperror.Render(w, apperror.Conflict("email already registered"))
		return
	} else if !errors.Is(err, pgx.ErrNoRows) {
		handleError(w, err)
		return
	}

	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		handleError(w, err)
		return
	}

	user, err := q.CreateUser(ctx, sqlcdb.CreateUserParams{
		Email:        req.Email,
		PasswordHash: hash,
	})
	if err != nil {
		handleError(w, err)
		return
	}

	var respName *string
	var respPhone *string

	// Save optional name/phone immediately if provided
	if req.Name != nil || req.Phone != nil {
		profile, profileErr := q.UpdateUserProfile(ctx, sqlcdb.UpdateUserProfileParams{
			ID:    user.ID,
			Name:  req.Name,
			Phone: req.Phone,
		})
		if profileErr == nil {
			respName = profile.Name
			respPhone = profile.Phone
		}
	}

	token, exp, err := auth.SignToken(user.ID, h.jwtSecret)
	if err != nil {
		handleError(w, err)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{
		"token":      token,
		"expires_at": exp,
		"user_id":    user.ID,
		"name":       respName,
		"phone":      respPhone,
		"email":      user.Email,
	})
}

// ── Me ───────────────────────────────────────────────────────────────────────

func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())
	user, err := sqlcdb.New(h.pool).GetUserByID(r.Context(), userID)
	if err != nil {
		handleError(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"user_id": user.ID,
		"email":   user.Email,
		"name":    user.Name,
		"phone":   user.Phone,
	})
}

// ── Update profile ────────────────────────────────────────────────────────────

type updateProfileRequest struct {
	Name  *string `json:"name"`
	Phone *string `json:"phone"`
}

func (h *AuthHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	userID, _ := auth.UserIDFromContext(r.Context())

	var req updateProfileRequest
	if err := decodeJSON(r, &req); err != nil {
		handleError(w, err)
		return
	}

	user, err := sqlcdb.New(h.pool).UpdateUserProfile(r.Context(), sqlcdb.UpdateUserProfileParams{
		ID:    userID,
		Name:  req.Name,
		Phone: req.Phone,
	})
	if err != nil {
		handleError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"user_id": user.ID,
		"email":   user.Email,
		"name":    user.Name,
		"phone":   user.Phone,
	})
}
