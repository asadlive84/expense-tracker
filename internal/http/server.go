package http

import (
	"net/http"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/asad/expense-tracker/internal/cache"
	"github.com/asad/expense-tracker/internal/domain/bucket"
	"github.com/asad/expense-tracker/internal/domain/person"
	"github.com/asad/expense-tracker/internal/domain/reminder"
	"github.com/asad/expense-tracker/internal/domain/report"
	"github.com/asad/expense-tracker/internal/domain/tag"
	"github.com/asad/expense-tracker/internal/domain/transaction"
	"github.com/asad/expense-tracker/internal/http/handlers"
	"github.com/asad/expense-tracker/internal/http/middleware"
	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
	"log/slog"
)

func NewRouter(pool *pgxpool.Pool, redisCache *cache.Cache, jwtSecret string, log *slog.Logger) http.Handler {
	if log == nil {
		log = slog.Default()
	}
	r := chi.NewRouter()

	// Middleware stack (outer to inner)
	r.Use(middleware.Recover(log))
	r.Use(middleware.RequestID)
	r.Use(middleware.Logging(log))
	r.Use(chimw.RealIP)

	// Services
	bucketSvc := bucket.NewService(pool)
	personSvc := person.NewService(pool)
	tagSvc := tag.NewService(pool)
	txSvc := transaction.NewService(pool, redisCache)
	reportSvc := report.NewService(pool, redisCache)
	reminderSvc := reminder.NewService(pool, txSvc)

	// Handlers
	authH := handlers.NewAuthHandler(pool, jwtSecret)
	bucketH := handlers.NewBucketHandler(bucketSvc)
	personH := handlers.NewPersonHandler(personSvc)
	tagH := handlers.NewTagHandler(tagSvc)
	txH := handlers.NewTransactionHandler(txSvc)
	reportH := handlers.NewReportHandler(reportSvc)
	reminderH := handlers.NewReminderHandler(reminderSvc)

	// Public routes
	r.Get("/v1/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	r.Post("/v1/auth/login", authH.Login)
	r.Post("/v1/auth/register", authH.Register)

	// Protected routes
	r.Group(func(r chi.Router) {
		r.Use(auth.RequireAuth(jwtSecret))

		r.Get("/v1/me", authH.Me)
		r.Patch("/v1/me", authH.UpdateProfile)

		r.Get("/v1/buckets", bucketH.List)
		r.Post("/v1/buckets", bucketH.Create)
		r.Patch("/v1/buckets/{id}", bucketH.Update)

		r.Get("/v1/people", personH.List)
		r.Post("/v1/people", personH.Create)
		r.Patch("/v1/people/{id}", personH.Update)

		r.Get("/v1/tags", tagH.List)
		r.Post("/v1/tags", tagH.Create)
		r.Patch("/v1/tags/{id}", tagH.Update)
		r.Delete("/v1/tags/{id}", tagH.Delete)

		r.Get("/v1/transactions", txH.List)
		r.Post("/v1/transactions", txH.Create)
		r.Patch("/v1/transactions/{id}", txH.Update)
		r.Delete("/v1/transactions/{id}", txH.Delete)

		r.Get("/v1/reports/bucket-balances", reportH.BucketBalances)
		r.Get("/v1/reports/person-balances", reportH.PersonBalances)
		r.Get("/v1/reports/tag-totals", reportH.TagTotals)
		r.Get("/v1/reports/summary", reportH.Summary)

		r.Get("/v1/reminders", reminderH.List)
		r.Post("/v1/reminders", reminderH.Create)
		r.Patch("/v1/reminders/{id}", reminderH.Update)
		r.Post("/v1/reminders/{id}/pay", reminderH.Pay)
		r.Post("/v1/reminders/{id}/skip", reminderH.Skip)
	})

	return r
}
