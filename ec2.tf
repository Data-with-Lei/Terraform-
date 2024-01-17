resource "aws_instance" "main" {
    ami = data.aws_ssm_parameter.instance_ami.value
    instance_type = "t3.micro"
    key_name = "smansible2"
    subnet_id = aws_subnet.public[0].id
    vpc_security_group_ids = ["sg-08fbc37c7cd952ff4"]
    tags = {
        "Name" = "${var.default_tags.env}-EC2"
    }
    user_data = base64encode(file("C:\\Users\\solei\\OneDrive\\skillstorm\\Terraform\\user.sh"))
}