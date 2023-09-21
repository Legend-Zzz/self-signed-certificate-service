package logic

import (
	"context"
	"errors"
	"os"
	"path/filepath"

	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type FileListLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewFileListLogic(ctx context.Context, svcCtx *svc.ServiceContext) *FileListLogic {
	return &FileListLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *FileListLogic) FileList(req *types.FileListReq) (resp []types.FileListResp, err error) {
	filetype := req.Type
	if filetype == "" {
		return nil, errors.New("type not specified")
	}
	if filetype != "cert" {
		return nil, errors.New("type not supported")
	}

	folderPath := "./out/"
	fileList := make([]types.FileListResp, 0)

	err = filepath.Walk(folderPath, func(filePath string, fileInfo os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !fileInfo.IsDir() {
			relativePath, _ := filepath.Rel(folderPath, filePath)

			fileData := types.FileListResp{
				Name: relativePath,
				Date: fileInfo.ModTime().Format("2006-01-02 15:04:05"),
			}
			fileList = append(fileList, fileData)
		}
		return nil
	})

	if err != nil {
		return nil, err
	}

	return fileList, nil
}
