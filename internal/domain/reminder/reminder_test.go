package reminder_test

import (
	"testing"
	"time"

	"github.com/asad/expense-tracker/internal/domain/reminder"
	"github.com/stretchr/testify/assert"
)

func TestAdvanceDueDate(t *testing.T) {
	tests := []struct {
		name           string
		current        time.Time
		recurrenceType string
		recurrenceDay  *int32
		want           time.Time
	}{
		{
			name:           "weekly",
			current:        time.Date(2026, 5, 1, 10, 0, 0, 0, time.UTC),
			recurrenceType: "weekly",
			want:           time.Date(2026, 5, 8, 10, 0, 0, 0, time.UTC),
		},
		{
			name:           "monthly",
			current:        time.Date(2026, 1, 31, 10, 0, 0, 0, time.UTC),
			recurrenceType: "monthly",
			want:           time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC), // clamp to Feb 28
		},
		{
			name:           "monthly with recurrence_day=31 in february",
			current:        time.Date(2026, 1, 15, 10, 0, 0, 0, time.UTC),
			recurrenceType: "monthly",
			recurrenceDay:  int32Ptr(31),
			want:           time.Date(2026, 2, 28, 10, 0, 0, 0, time.UTC),
		},
		{
			name:           "monthly with recurrence_day=15",
			current:        time.Date(2026, 1, 1, 10, 0, 0, 0, time.UTC),
			recurrenceType: "monthly",
			recurrenceDay:  int32Ptr(15),
			want:           time.Date(2026, 2, 15, 10, 0, 0, 0, time.UTC),
		},
		{
			name:           "yearly",
			current:        time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC),
			recurrenceType: "yearly",
			want:           time.Date(2027, 3, 1, 0, 0, 0, 0, time.UTC),
		},
		{
			name:           "none returns same date",
			current:        time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC),
			recurrenceType: "none",
			want:           time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC),
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got := reminder.AdvanceDueDate(tc.current, tc.recurrenceType, tc.recurrenceDay)
			assert.Equal(t, tc.want, got)
		})
	}
}

func int32Ptr(i int32) *int32 { return &i }
