package state

import "net/netip"

var DefaultIpv4Address = "172.18.0.1/30"
var DefaultIpv6Address = "fdfe:dcba:9876::1/126"

type AndroidVpnOptions struct {
	Enable           bool           `json:"enable"`
	Port             int            `json:"port"`
	AccessControl    *AccessControl `json:"accessControl"`
	AllowBypass      bool           `json:"allowBypass"`
	SystemProxy      bool           `json:"systemProxy"`
	BypassDomain     bool           `json:"bypassDomain"`
	Ipv4Address      string         `json:"ipv4Address"`
	Ipv6Address      string         `json:"ipv6Address"`
	DnsServerAddress string         `json:"dnsAddress"`
}

type AccessControl struct {
	Mode              string   `json:"mode"`
	AcceptList        []string `json:"acceptList"`
	RejectList        []string `json:"rejectList"`
	IsFilterSystemApp bool     `json:"isFilterSystemApp"`
}

type AndroidVpnRawOptions struct {
	AccessControl *AccessControl `json:"accessControl"`
	AllowBypass   bool           `json:"allowBypass"`
	SystemProxy   bool           `json:"systemProxy"`
	Ipv6          bool           `json:"ipv6"`
	BypassDomain  bool           `json:"bypassDomain"`
}

type State struct {
	AndroidVpnRawOptions
	CurrentProfileName string `json:"currentProfileName"`
	OnlyProxy          bool   `json:"onlyProxy"`
}

var CurrentState State

func GetIpv6Address() string {
	if CurrentState.Ipv6 {
		return DefaultIpv6Address
	} else {
		return ""
	}
}

func GetDnsServerAddress() string {
	addr, _ := netip.ParseAddr(DefaultIpv4Address)
	return addr.String()
}
