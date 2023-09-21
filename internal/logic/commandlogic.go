package logic

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"self-signed-certificate-service/internal/svc"
	"self-signed-certificate-service/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type CommandLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCommandLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CommandLogic {
	return &CommandLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CommandLogic) executeCommand(cmd string) (string, error) {
	cmdArgs := strings.Fields(cmd)
	command := exec.Command(cmdArgs[0], cmdArgs[1:]...)
	output, err := command.CombinedOutput()
	return strings.TrimSpace(string(output)), err
}

func (l *CommandLogic) logCommandAndResult(cmd, result string) error {
	log := fmt.Sprintf("------------------------------%s------------------------------\n%s\n%s\n", time.Now().Format("2006-01-02 15:04:05"), cmd, result)
	logName := "./result.log"

	f, err := os.OpenFile(logName, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0644)
	if err != nil {
		return err
	}
	defer func(f *os.File) {
		_ = f.Close()
	}(f)

	oldData, _ := os.ReadFile(logName)

	f, err = os.OpenFile(logName, os.O_RDWR|os.O_CREATE, 0644)
	if err != nil {
		return err
	}
	defer func(f *os.File) {
		_ = f.Close()
	}(f)

	if _, err := f.Write([]byte(log)); err != nil {
		return err
	}
	if _, err := f.Write(oldData); err != nil {
		return err
	}

	return nil
}

func (l *CommandLogic) Command(req *types.CommandReq) (resp *types.CommandResp, err error) {
	var cmd string
	Selection := req.Selection
	switch Selection {
	case "all":
		cmd = "./scripts/gen.cert.sh"
		if req.Domain != "" {
			cmd += " -d " + req.Domain
		}
		if req.IP != "" {
			cmd += " -i " + req.IP
		}
		if req.CASubject != "" {
			cmd += " -s " + strings.Replace(req.CASubject, " ", "-", -1)
		}
		if req.CAValidityDays != 0 {
			cmd += " -D " + strconv.Itoa(req.CAValidityDays)
		}
		if req.RootSubject != "" {
			cmd += " -rs " + strings.Replace(req.RootSubject, " ", "-", -1)
		}
		if req.RootValidityDays != 0 {
			cmd += " -rD " + strconv.Itoa(req.RootValidityDays)
		}
		if req.SerialNumber != 0 {
			cmd += " -sn " + strconv.Itoa(req.SerialNumber)
		}
	case "rootOnly":
		cmd = "./scripts/gen.root.sh"
		if req.RootOnlySubject != "" {
			cmd += " -s " + strings.Replace(req.RootOnlySubject, " ", "-", -1)
		}
		if req.RootOnlyValidityDays != 0 {
			cmd += " -d " + strconv.Itoa(req.RootOnlyValidityDays)
		}
		if req.RootOnlySerialNumber != 0 {
			cmd += " -sn " + strconv.Itoa(req.RootOnlySerialNumber)
		}
	}

	result, _ := l.executeCommand(cmd)

	err = l.logCommandAndResult(cmd, result)

	if err != nil {
		resp = &types.CommandResp{
			Message: "failed",
		}
		return resp, err
	}

	return &types.CommandResp{
		Message: "success",
	}, nil
}
