Working with vCloud Director
====

Naturally we've learnt a fair bit about vCloud Director whilst developing these tools. Hopefully this document will help reduce the on boarding time for new developers and users of these tools.


### vCloud entities

vCloud entities - also called 'types' by the vCloud Query API - are the respective components within the vCloud Director product.

Each vCloud Entity has a unique id and href. The href generally points to the GET request needed to retrieve this item. The id in most cases is a uuid, but in some cases (vApps, vAppTemplate, VM) has a prefix (respectively: vapp-, vappTemplate-, vm-).

A complete list of these types can be found by running the 'vcloud-query' tool with no options.


However, as users of vCloud Director, we are primarily concerned with a subset of these:

#### Organization

A vCloud organisation is an administrative wrapper. Its primary purpose is to allow a vCloud provider to provide an administrative zone to a client/tenant. This is in effect the top-level for a vCloud tenant. We can create users & groups within that.

#### vDC

Sitting within an organisation is a vDC (aka orgVdc). Technically it maps to physical vSphere resources at the provider, but from an organisational perspective this provides a wrapper around vApps, networks. It's worth picturing these as an isolated room within a physical datacentre, as there is no guarantee that they are geographically separated from one another.

vDCs have their own networks (orgVdcNetworks), and contain vApps. Each vDC can optionally have an EdgeGateway at its border.

Questions needing answering here: 

* Can vDC1 and vDC2 share the same physical hardware?
* Can a vDC have multiple EdgeGateways?

#### orgVdcStorageProfile

Technically, Storage Profiles map to physical storage at the provider. Depending on their setup, there may be several storage profiles available, or just one. A provider can limit the available storage profiles to a tenant on a per-vDC basis.

Storage Profiles can be useful for ensuring known-good separation of storage at a provider (assuming their physical setup supports this), or for providing different service levels (e.g. IOPS, availability, redundancy).

Notes on general usage:

* The same storage profile assigned to two different vDCs will have a different id/href element.
* The provider can limit the available storage profiles on a per-vDC basis.

Questions needing answering here:

* Is is possible for a StorageProfile assigned to one vDC to have a different name to the same StorageProfile assigned to a different vDC?

#### edgeGateway

EdgeGateways are a representation of a vShield Edge appliance. There can be zero or one assigned to a vDC (confirm: might be possible to have >1, but rarely needed).

EdgeGateways provide the following services:

* Routing - (full details TBC)
* NatService - DNAT and SNAT rules from one network to another.
* FirewallService - basic firewall functionality
* DhcpService - basic DHCP server to provide IPs to connected networks.
* LoadBalancerService - Basic HTTP and TCP load balancer service.
* VPN Service - IPSec (and others?)

Questions needing answering:

* Statefulness of Firewall rules?
* IPv6 support?
* Specifically what routing is available?
* Difference between full and non-full configuration
* Provider only functionality?
* Effect of updating rules?
* What operations on other elements (e.g. orgVdcNetworks) add configuration to the EdgeGateway?

#### orgVdcNetwork

At a vDC level, virtual networks can be defined that have the following type:

* bridged -- connected to an external (provider managed) physical network
* natRouted -- internal to the vDC, connected to its EdgeGateway and the NatService on that EdgeGateway.
* isolated -- internal to the vDC, de-coupled from the EdgeGateway. (TBC: DHCPService is available on the orgVdcNetwork, not sure if this is provided by the EdgeGateway technically)

Each orgVdcNetwork can be 'shared' - if so, it is available to ALL vDCs in that organisation.

Notes:

* An orgVdcNetwork is defined within a vDC.
* Its name is unique within that vDC.
* It is possible to create a shared orgVdcNetwork in one vDC with the same name as a shared orgVdcNetwork from another vDC. This has the net result of having two orgVdcNetworks available in a vDC with the same name. 'Yey'.


#### catalog & catalogItem

A catalog is a store of vAppTemplates, and media (ISOs, floppy images), which in turn are catalogItems. 

There can be multiple catalogs per organisation. There can also be public catalogs which are shared across organisations (TBC: these can only be created by Providers?)

It is possible to upload media into a catalog.

TBC: Upload of vApp?

TBC: the process of creating a vAppTemplate pushes it into a catalog. 

#### vAppTemplate

A vAppTemplate is the typical means by which vApps are instantiated. vApps can be turned into templates.


#### vApp

vApps are somewhat confusing. Feature-wise, they can be considered a 'mini vDC', though there are good reasons to avoid this analogy and treat them as a simple wrapper around a single VM. VMware are reported to be removing the requirement to have VMs contained within vApps in future (6.x+?) versions of vCloud Director.

As-is though vApps contain:

  * zero or more VMs.
  * vAppNetworks

At GOV.UK, we standardise on single-VM-per-vApp, and only use vAppNetworks bridged directly to orgVdcNetworks. This is on the recommendation from multiple providers.

Notes on general use:

* vApp names are unique across the organisation.
  
#### VM

Last but not least - VMs. VMs sit within vApps, and are the fundamental compute resource, mapping to VMs in the underlying vSphere.

Notes on general use:

* VM names are not unique in an organization. This is quite annoying.
* VMs also have a 'ComputerName' element, which does not connect to the entity name. This again does not need to be unique.
* VM names must be unique within a vApp (assuming >1 vm per vApp)
* The ComputerName does not need to be unique within a vApp.
* TBC: VMs can only be in one storage profile?


