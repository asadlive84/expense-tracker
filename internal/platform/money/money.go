package money

import "fmt"

// FormatBDT formats paisa as a BDT string, e.g. 150025 → "1500.25 BDT"
func FormatBDT(paisa int64) string {
	taka := paisa / 100
	paise := paisa % 100
	if paise < 0 {
		paise = -paise
	}
	return fmt.Sprintf("%d.%02d BDT", taka, paise)
}

// PaisaToTaka converts paisa to taka as a float64 (for display only).
func PaisaToTaka(paisa int64) float64 {
	return float64(paisa) / 100.0
}
