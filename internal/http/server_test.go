package http_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	appdb "github.com/asad/expense-tracker/internal/db"
	apphttp "github.com/asad/expense-tracker/internal/http"
	"github.com/asad/expense-tracker/internal/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testJWTSecret = "integration-test-jwt-secret-32ch"

func newTestServer(t *testing.T) *httptest.Server {
	t.Helper()
	db := testutil.NewTestDB(t)

	err := appdb.SeedUser(context.Background(), db.Pool, "user@test.com", "password123")
	require.NoError(t, err)

	router := apphttp.NewRouter(db.Pool, db.Cache, testJWTSecret, nil)
	// nil logger is fine for tests — replace with noop logger
	return httptest.NewServer(router)
}

func TestHealthz(t *testing.T) {
	db := testutil.NewTestDB(t)
	router := apphttp.NewRouter(db.Pool, db.Cache, testJWTSecret, nil)
	srv := httptest.NewServer(router)
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/v1/healthz")
	require.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
}

func TestLoginFlow(t *testing.T) {
	db := testutil.NewTestDB(t)
	err := appdb.SeedUser(context.Background(), db.Pool, "admin@test.com", "hunter2")
	require.NoError(t, err)

	router := apphttp.NewRouter(db.Pool, db.Cache, testJWTSecret, nil)
	srv := httptest.NewServer(router)
	defer srv.Close()

	t.Run("correct credentials", func(t *testing.T) {
		body, _ := json.Marshal(map[string]string{"email": "admin@test.com", "password": "hunter2"})
		resp, err := http.Post(srv.URL+"/v1/auth/login", "application/json", bytes.NewReader(body))
		require.NoError(t, err)
		assert.Equal(t, http.StatusOK, resp.StatusCode)

		var result map[string]any
		_ = json.NewDecoder(resp.Body).Decode(&result)
		assert.NotEmpty(t, result["token"])
	})

	t.Run("wrong password", func(t *testing.T) {
		body, _ := json.Marshal(map[string]string{"email": "admin@test.com", "password": "wrong"})
		resp, err := http.Post(srv.URL+"/v1/auth/login", "application/json", bytes.NewReader(body))
		require.NoError(t, err)
		assert.Equal(t, http.StatusUnauthorized, resp.StatusCode)
	})

	t.Run("protected endpoint without token", func(t *testing.T) {
		resp, err := http.Get(srv.URL + "/v1/me")
		require.NoError(t, err)
		assert.Equal(t, http.StatusUnauthorized, resp.StatusCode)
	})

	t.Run("protected endpoint with valid token", func(t *testing.T) {
		body, _ := json.Marshal(map[string]string{"email": "admin@test.com", "password": "hunter2"})
		loginResp, _ := http.Post(srv.URL+"/v1/auth/login", "application/json", bytes.NewReader(body))
		var loginResult map[string]any
		_ = json.NewDecoder(loginResp.Body).Decode(&loginResult)
		token := loginResult["token"].(string)

		req, _ := http.NewRequest(http.MethodGet, srv.URL+"/v1/me", nil)
		req.Header.Set("Authorization", "Bearer "+token)
		resp, err := http.DefaultClient.Do(req)
		require.NoError(t, err)
		assert.Equal(t, http.StatusOK, resp.StatusCode)
	})
}
