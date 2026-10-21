// Package authctx — пользователь запроса в context (ставит middleware auth, читают sync/media).
package authctx

import "context"

type key struct{}

// WithUser возвращает context с id пользователя.
func WithUser(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, key{}, userID)
}

// UserID — id пользователя или "" (запрос без авторизации).
func UserID(ctx context.Context) string {
	id, _ := ctx.Value(key{}).(string)
	return id
}
