package handler

import (
	"net/http"

	"self-signed-certificate-service/internal/logic"
	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/rest/httpx"
)

func CommandHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.CommandReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := logic.NewCommandLogic(r.Context(), svcCtx)
		resp, err := l.Command(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
