package logic

import (
	"context"
	"errors"
	"os"

	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type FileLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewFileLogic(ctx context.Context, svcCtx *svc.ServiceContext) *FileLogic {
	return &FileLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *FileLogic) File(req *types.FileReq) (resp *types.FileResp, err error) {
	name := req.Name
	filetype := req.Type
	method := req.Method
	if filetype == "" {
		return nil, errors.New("type not specified")
	}
	if filetype != "cert" {
		return nil, errors.New("type not supported")
	}
	if name == "" {
		return nil, errors.New("name not specified")
	}
	if method == "" {
		return nil, errors.New("method not specified")
	}
	folderPath := "./out/"
	if method == "view" {
		Context, err := os.ReadFile(folderPath + name)
		if err != nil {
			return nil, errors.New("unable to view file")
		}
		if len(Context) == 0 {
			return nil, errors.New("file content is empty")
		}
		resp = &types.FileResp{
			Context: string(Context),
			Message: "success",
		}
	}
	if method == "delete" {
		err = os.Remove(folderPath + name)
		if err != nil {
			return nil, errors.New("unable to delete file")
		}
		resp = &types.FileResp{
			Message: "success",
		}
	}
	return resp, nil
}
