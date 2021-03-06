#!/bin/sh
#
# Create Glance user and service.

keystone_host="<%=  @KEYSTONE_HOST %>"
admin_port="<%= @KEYSTONE_ADMIN_PORT %>"
admin_token="<%= @ADMIN_TOKEN %>"
region="<%= @region %>"

admin_user_pass="<%= @admin_user_pass %>"
glance_user_pass="<%= @GLANCE_USER_PASSWORD %>"

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=${admin_user_pass}
export OS_AUTH_URL=http://${keystone_host}:${admin_port}/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

# Creat the Glance user.
get_user_id () {
        openstack user list | awk -F'|' '{print $2,$3}' | awk -vuser_name="$1" ' $2 == user_name  {print $1} '
}

user_id=$(get_user_id glance)

if [ "$user_id" ]; then
        echo "Found existing user id: $user_id"
else
        # Create the user
        openstack user create glance  --domain default --password="$glance_user_pass"

        # Add the admin role to glance user
        openstack role add --project service --user glance admin

        user_id=$(get_user_id glance)

        if [ "$user_id" ]; then
                echo "Created new User: $user_id"
        else
                echo "ERROR: Failed to create User."
                exit 1
        fi
fi

#Create a Glance service
get_service_id () {
        openstack service list | awk -F'|' '{print $2,$3,$4}' | awk -vservice_name="$1" -vservice_type="$2" '
                 $2 == service_name && $3 == service_type {print $1} '
}

service_id=$(get_service_id glance image )

if [ "$service_id" ]; then
        echo "Found existing service id: $service_id"
else
        # Create the service
        openstack service create --name glance  --description "OpenStack Image service" image

        service_id=$(get_service_id glance image)

        if [ "$service_id" ]; then
                echo "Created new service id: $service_id"
        else
                echo "ERROR: Failed to create service."
                exit 1
        fi
fi

# Create the Image Service API endpoints
get_keystone_endpoint () {
        openstack endpoint list |  awk -F'|' '{print $2,$3,$4,$5}' | awk -vservice_name="$1" -vservice_type="$2" '
               $3 == service_name && $4 == service_type {print $1} '
    }

endpoint_id=$(get_keystone_endpoint glance image )

if [ "$endpoint_id" ]; then
        echo "Found existing endpoint: $endpoint_id"
else
   openstack endpoint create --region "$region" image public http://"$keystone_host":9292
   openstack endpoint create --region "$region" image internal http://"$keystone_host":9292
   openstack endpoint create --region "$region" image admin http://"$keystone_host":9292
fi            
