package jdocs

import (
	"anki/config"
	"anki/log"
	"anki/token"
	"anki/util"
	"clad/cloud"
	"context"
	"fmt"

	pb "github.com/anki/sai-jdocs/proto/jdocspb"
	"github.com/gwatts/rootcerts"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

type conn struct {
	conn   *grpc.ClientConn
	client pb.JdocsClient
	tok    token.Accessor
}

var (
	// This is a global variabe used for performance issues (not referenced outside this file)
	defaultTLSCert = credentials.NewClientTLSFromCert(rootcerts.ServerCertPool(), "")
)

func newConn(ctx context.Context, opts *options) (*conn, error) {
	var dialOpts []grpc.DialOption
	dialOpts = append(dialOpts, util.CommonGRPC()...)
	dialOpts = append(dialOpts, grpc.WithTransportCredentials(defaultTLSCert))
	if opts.tokener != nil {
		creds, err := opts.tokener.Credentials()
		if err != nil {
			return nil, err
		}
		dialOpts = append(dialOpts, grpc.WithPerRPCCredentials(creds))
	}
	rpcConn, err := grpc.DialContext(ctx, config.Env.JDocs, dialOpts...)
	if err != nil {
		return nil, err
	}

	rpcClient := pb.NewJdocsClient(rpcConn)

	ret := &conn{
		conn:   rpcConn,
		client: rpcClient,
		tok:    opts.tokener}
	return ret, nil
}

func (c *conn) close() error {
	return c.conn.Close()
}

func (c *conn) handleRequest(ctx context.Context, req *cloud.DocRequest) (*cloud.DocResponse, error) {
	switch req.Tag() {
	case cloud.DocRequestTag_Read:
		return c.readRequest(ctx, req.GetRead())
	case cloud.DocRequestTag_Write:
		return c.writeRequest(ctx, req.GetWrite())
	case cloud.DocRequestTag_DeleteReq:
		return c.deleteRequest(ctx, req.GetDeleteReq())
	}
	err := fmt.Errorf("Major error: received unknown tag %d", req.Tag())
	log.Println(err)
	return nil, err
}

var connectErrorResponse = cloud.NewDocResponseWithErr(&cloud.ErrorResponse{Err: cloud.DocError_ErrorConnecting})

func (c *conn) writeRequest(ctx context.Context, cladReq *cloud.WriteRequest) (*cloud.DocResponse, error) {
	req := (*cladWriteReq)(cladReq).toProto()
	resp, err := c.client.WriteDoc(ctx, req)
	if err != nil {
		return connectErrorResponse, err
	}
	return cloud.NewDocResponseWithWrite((*protoWriteResp)(resp).toClad()), nil
}

func (c *conn) readRequest(ctx context.Context, cladReq *cloud.ReadRequest) (*cloud.DocResponse, error) {
	req := (*cladReadReq)(cladReq).toProto()
	resp, err := c.client.ReadDocs(ctx, req)
	if err != nil {
		return connectErrorResponse, err
	}
	return cloud.NewDocResponseWithRead((*protoReadResp)(resp).toClad()), nil
}

func (c *conn) deleteRequest(ctx context.Context, cladReq *cloud.DeleteRequest) (*cloud.DocResponse, error) {
	req := (*cladDeleteReq)(cladReq).toProto()
	_, err := c.client.DeleteDoc(ctx, req)
	if err != nil {
		return connectErrorResponse, err
	}
	return cloud.NewDocResponseWithDeleteResp(&cloud.Void{}), nil
}

func (c *client) handleConnectionless(req *cloud.DocRequest) (bool, *cloud.DocResponse, error) {
	switch req.Tag() {
	case cloud.DocRequestTag_User:
		r, e := c.handleUserRequest()
		return true, r, e
	case cloud.DocRequestTag_Thing:
		r, e := c.handleThingRequest()
		return true, r, e
	}
	return false, nil, nil
}

func (c *client) handleUserRequest() (*cloud.DocResponse, error) {
	var user string
	if c.opts.tokener != nil {
		user = c.opts.tokener.UserID()
	}
	return cloud.NewDocResponseWithUser(&cloud.UserResponse{UserId: user}), nil
}

func (c *client) handleThingRequest() (*cloud.DocResponse, error) {
	thing := c.opts.tokener.IdentityProvider().CertCommonName()
	return cloud.NewDocResponseWithThing(&cloud.ThingResponse{ThingName: thing}), nil
}
