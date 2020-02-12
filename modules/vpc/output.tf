output "tfVPC_id" {
  value = "${aws_vpc.tfVPC.id}"
}

output "tfEIP_ip" {
  value = "${aws_eip.tfEIP}"
}

