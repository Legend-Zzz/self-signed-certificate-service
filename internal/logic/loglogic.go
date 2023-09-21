package logic

import (
	"context"
	"os"

	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type LogLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewLogLogic(ctx context.Context, svcCtx *svc.ServiceContext) *LogLogic {
	return &LogLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *LogLogic) Log() (resp *types.LogResp, err error) {
	logName := "./result.log"
	f, _ := os.OpenFile(logName, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0644)

	defer func(f *os.File) {
		_ = f.Close()
	}(f)
	Context, _ := os.ReadFile(logName)

	return &types.LogResp{
		Context: string(Context),
	}, nil
}
