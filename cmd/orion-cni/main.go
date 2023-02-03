package main

import (
	"github.com/containernetworking/cni/pkg/skel"
	"github.com/containernetworking/cni/pkg/types"
	"github.com/containernetworking/cni/pkg/version"
)

type CNIConfig struct {
	types.NetConf
}

func add(args *skel.CmdArgs) error {
	return nil
}

func delete(args *skel.CmdArgs) error {
	return nil
}

func check(args *skel.CmdArgs) error {
	return nil
}

func main() {
	versions := version.PluginSupports("1.0.0")
	about := "Orion CNI"
	skel.PluginMain(add, check, delete, versions, about)
}
