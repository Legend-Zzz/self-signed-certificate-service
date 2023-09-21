package handler

import (
	"net/http"

	"self-signed-certificate-service/internal/logic"
	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/rest/httpx"
)

func FileListHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.FileListReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := logic.NewFileListLogic(r.Context(), svcCtx)
		resp, err := l.FileList(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
