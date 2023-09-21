package handler

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"self-signed-certificate-service/internal/logic"
	"self-signed-certificate-service/internal/svc"
)

func LogHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		l := logic.NewLogLogic(r.Context(), svcCtx)
		resp, err := l.Log()
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
