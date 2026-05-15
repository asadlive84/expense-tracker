package auth_test

import (
	"testing"

	"github.com/asad/expense-tracker/internal/auth"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testSecret = "test-secret-key-must-be-32-chars!"

func TestHashAndVerifyPassword(t *testing.T) {
	hash, err := auth.HashPassword("secret123")
	require.NoError(t, err)
	assert.NotEmpty(t, hash)

	assert.NoError(t, auth.VerifyPassword(hash, "secret123"))
	assert.Error(t, auth.VerifyPassword(hash, "wrong"))
}

func TestJWTRoundTrip(t *testing.T) {
	id := uuid.New()
	token, exp, err := auth.SignToken(id, testSecret)
	require.NoError(t, err)
	assert.NotEmpty(t, token)
	assert.False(t, exp.IsZero())

	parsed, err := auth.ParseToken(token, testSecret)
	require.NoError(t, err)
	assert.Equal(t, id, parsed)
}

func TestParseToken_WrongSecret(t *testing.T) {
	id := uuid.New()
	token, _, err := auth.SignToken(id, testSecret)
	require.NoError(t, err)

	_, err = auth.ParseToken(token, "other-secret-key-32-chars-xxxxx!")
	assert.Error(t, err)
}
