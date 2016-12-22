provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_autoscaling_group" "master-ap-northeast-1a-masters-cloud-test-dev-bite-io" {
  name = "master-ap-northeast-1a.masters.cloud-test.dev-bite.io"
  launch_configuration = "${aws_launch_configuration.master-ap-northeast-1a-masters-cloud-test-dev-bite-io.id}"
  max_size = 1
  min_size = 1
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-cloud-test-dev-bite-io.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "cloud-test.dev-bite.io"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "master-ap-northeast-1a.masters.cloud-test.dev-bite.io"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/master"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-cloud-test-dev-bite-io" {
  name = "nodes.cloud-test.dev-bite.io"
  launch_configuration = "${aws_launch_configuration.nodes-cloud-test-dev-bite-io.id}"
  max_size = 5
  min_size = 5
  vpc_zone_identifier = ["${aws_subnet.ap-northeast-1a-cloud-test-dev-bite-io.id}", "${aws_subnet.ap-northeast-1c-cloud-test-dev-bite-io.id}"]
  tag = {
    key = "KubernetesCluster"
    value = "cloud-test.dev-bite.io"
    propagate_at_launch = true
  }
  tag = {
    key = "Name"
    value = "nodes.cloud-test.dev-bite.io"
    propagate_at_launch = true
  }
  tag = {
    key = "k8s.io/role/node"
    value = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-events-cloud-test-dev-bite-io" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "ap-northeast-1a.etcd-events.cloud-test.dev-bite.io"
    "k8s.io/etcd/events" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "ap-northeast-1a-etcd-main-cloud-test-dev-bite-io" {
  availability_zone = "ap-northeast-1a"
  size = 20
  type = "gp2"
  encrypted = false
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "ap-northeast-1a.etcd-main.cloud-test.dev-bite.io"
    "k8s.io/etcd/main" = "ap-northeast-1a/ap-northeast-1a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_iam_instance_profile" "masters-cloud-test-dev-bite-io" {
  name = "masters.cloud-test.dev-bite.io"
  roles = ["${aws_iam_role.masters-cloud-test-dev-bite-io.name}"]
}

resource "aws_iam_instance_profile" "nodes-cloud-test-dev-bite-io" {
  name = "nodes.cloud-test.dev-bite.io"
  roles = ["${aws_iam_role.nodes-cloud-test-dev-bite-io.name}"]
}

resource "aws_iam_role" "masters-cloud-test-dev-bite-io" {
  name = "masters.cloud-test.dev-bite.io"
  assume_role_policy = "${file("data/aws_iam_role_masters.cloud-test.dev-bite.io_policy")}"
}

resource "aws_iam_role" "nodes-cloud-test-dev-bite-io" {
  name = "nodes.cloud-test.dev-bite.io"
  assume_role_policy = "${file("data/aws_iam_role_nodes.cloud-test.dev-bite.io_policy")}"
}

resource "aws_iam_role_policy" "masters-cloud-test-dev-bite-io" {
  name = "masters.cloud-test.dev-bite.io"
  role = "${aws_iam_role.masters-cloud-test-dev-bite-io.name}"
  policy = "${file("data/aws_iam_role_policy_masters.cloud-test.dev-bite.io_policy")}"
}

resource "aws_iam_role_policy" "nodes-cloud-test-dev-bite-io" {
  name = "nodes.cloud-test.dev-bite.io"
  role = "${aws_iam_role.nodes-cloud-test-dev-bite-io.name}"
  policy = "${file("data/aws_iam_role_policy_nodes.cloud-test.dev-bite.io_policy")}"
}

resource "aws_internet_gateway" "cloud-test-dev-bite-io" {
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "cloud-test.dev-bite.io"
  }
}

resource "aws_key_pair" "kubernetes-cloud-test-dev-bite-io-61b052f22b66b90ce0e8f8cb7a251992" {
  key_name = "kubernetes.cloud-test.dev-bite.io-61:b0:52:f2:2b:66:b9:0c:e0:e8:f8:cb:7a:25:19:92"
  public_key = "${file("data/aws_key_pair_kubernetes.cloud-test.dev-bite.io-61b052f22b66b90ce0e8f8cb7a251992_public_key")}"
}

resource "aws_launch_configuration" "master-ap-northeast-1a-masters-cloud-test-dev-bite-io" {
  name_prefix = "master-ap-northeast-1a.masters.cloud-test.dev-bite.io-"
  image_id = "ami-a19c3ac0"
  instance_type = "t2.large"
  key_name = "${aws_key_pair.kubernetes-cloud-test-dev-bite-io-61b052f22b66b90ce0e8f8cb7a251992.id}"
  iam_instance_profile = "${aws_iam_instance_profile.masters-cloud-test-dev-bite-io.id}"
  security_groups = ["${aws_security_group.masters-cloud-test-dev-bite-io.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_master-ap-northeast-1a.masters.cloud-test.dev-bite.io_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-cloud-test-dev-bite-io" {
  name_prefix = "nodes.cloud-test.dev-bite.io-"
  image_id = "ami-a19c3ac0"
  instance_type = "t2.large"
  key_name = "${aws_key_pair.kubernetes-cloud-test-dev-bite-io-61b052f22b66b90ce0e8f8cb7a251992.id}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes-cloud-test-dev-bite-io.id}"
  security_groups = ["${aws_security_group.nodes-cloud-test-dev-bite-io.id}"]
  associate_public_ip_address = true
  user_data = "${file("data/aws_launch_configuration_nodes.cloud-test.dev-bite.io_user_data")}"
  root_block_device = {
    volume_type = "gp2"
    volume_size = 20
    delete_on_termination = true
  }
  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id = "${aws_route_table.cloud-test-dev-bite-io.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.cloud-test-dev-bite-io.id}"
}

resource "aws_route_table" "cloud-test-dev-bite-io" {
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "cloud-test.dev-bite.io"
  }
}

resource "aws_route_table_association" "ap-northeast-1a-cloud-test-dev-bite-io" {
  subnet_id = "${aws_subnet.ap-northeast-1a-cloud-test-dev-bite-io.id}"
  route_table_id = "${aws_route_table.cloud-test-dev-bite-io.id}"
}

resource "aws_route_table_association" "ap-northeast-1c-cloud-test-dev-bite-io" {
  subnet_id = "${aws_subnet.ap-northeast-1c-cloud-test-dev-bite-io.id}"
  route_table_id = "${aws_route_table.cloud-test-dev-bite-io.id}"
}

resource "aws_security_group" "masters-cloud-test-dev-bite-io" {
  name = "masters.cloud-test.dev-bite.io"
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  description = "Security group for masters"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "masters.cloud-test.dev-bite.io"
  }
}

resource "aws_security_group" "nodes-cloud-test-dev-bite-io" {
  name = "nodes.cloud-test.dev-bite.io"
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  description = "Security group for nodes"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "nodes.cloud-test.dev-bite.io"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  source_security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  source_security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  source_security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  source_security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_security_group_rule" "https-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type = "egress"
  security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-master" {
  type = "ingress"
  security_group_id = "${aws_security_group.masters-cloud-test-dev-bite-io.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node" {
  type = "ingress"
  security_group_id = "${aws_security_group.nodes-cloud-test-dev-bite-io.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-northeast-1a-cloud-test-dev-bite-io" {
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  cidr_block = "172.20.32.0/19"
  availability_zone = "ap-northeast-1a"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "ap-northeast-1a.cloud-test.dev-bite.io"
  }
}

resource "aws_subnet" "ap-northeast-1c-cloud-test-dev-bite-io" {
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  cidr_block = "172.20.96.0/19"
  availability_zone = "ap-northeast-1c"
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "ap-northeast-1c.cloud-test.dev-bite.io"
  }
}

resource "aws_vpc" "cloud-test-dev-bite-io" {
  cidr_block = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "cloud-test.dev-bite.io"
  }
}

resource "aws_vpc_dhcp_options" "cloud-test-dev-bite-io" {
  domain_name = "ap-northeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    KubernetesCluster = "cloud-test.dev-bite.io"
    Name = "cloud-test.dev-bite.io"
  }
}

resource "aws_vpc_dhcp_options_association" "cloud-test-dev-bite-io" {
  vpc_id = "${aws_vpc.cloud-test-dev-bite-io.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.cloud-test-dev-bite-io.id}"
}