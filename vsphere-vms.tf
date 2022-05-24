data "vsphere_datacenter" "datacenter" {
    name = "Expense Servers"
  }

data "vsphere_datastore" "datastore" {
  name          = "Evija Datastore"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name = "terraform"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "evija.gcl.lgsdirect.com"
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_virtual_machine" "template" {
  name          = "terraform_packer_ubuntu_20_04_image"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


resource "vsphere_virtual_machine" "vm1" {
  name             = "k8s-master"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  guest_id         = "ubuntu64Guest"

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  disk {
    label = "disk0"
    size  = "50"
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

}

resource "vsphere_virtual_machine" "vm2" {
  name             = "k8s-workernode1"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  guest_id         = "ubuntu64Guest"

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  disk {
    label = "disk0"
    size  = "50"
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }
}

resource "vsphere_virtual_machine" "vm3" {
  name             = "k8s-workernode2"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  guest_id         = "ubuntu64Guest"

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  disk {
    label = "disk0"
    size  = "50"
  }


  network_interface {
    network_id = data.vsphere_network.network.id
  }
}

resource "null_resource" provisioner{
  depends_on = [vsphere_virtual_machine.vm1, vsphere_virtual_machine.vm2, vsphere_virtual_machine.vm3 ]

  provisioner "local-exec" {
    command = "ansible-playbook install-k8s-requirements.yml; sleep 120"
  }
}
