local move_docker_to_home = false
local ros = false

dnf_install "dnf-plugins-core"

dnf_install [[
    astyle
]]

-- AWS
if UPDATE or not installed "aws" then
    pip_install "awscli boto3 pre-commit"
end

-- Docker
if not installed "docker" then
    -- https://docs.docker.com/engine/install/fedora/
    run "sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo --overwrite"
    dnf_install [[
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ]]
end

db:once(FORCE, "docker_configured", function()
    run { "sudo groupadd docker || true" }
    run { "sudo usermod -a -G docker", USER }
    run { "sudo systemctl enable docker || true" }
    run "sudo systemctl start docker || true"
end)

if move_docker_to_home then
    if not fs.is_dir "/home/docker" then
        print "Move /var/lib/docker to /home/docker"
        run "sudo service docker stop"
        if fs.is_dir "/var/lib/docker" then
            print "Copy /var/lib/docker to /home/docker"
            run "sudo mv /var/lib/docker /home/docker"
        else
            print "Create /home/docker"
            run "sudo mkdir /home/docker"
        end
        print "Link /var/lib/docker to /home/docker"
        run "sudo ln -s -f /home/docker /var/lib/docker"
        run "sudo service docker start || true"
    end
end

pip_install [[
    appdirs
    awscli
    click
    google-api-python-client
    google-auth-httplib2
    google-auth-oauthlib
    junitparser
    junit-xml
    matplotlib
    pandas
    pyaml
    pydantic
    PyQt6
    python-can
    scipy
    tftpy
    tqdm
]]

-- ROS: http://wiki.ros.org/Installation/Source
if ros then

    if FORCE or not installed "rosXXX" then

        dnf_install [[
            curl
            cmake
            gcc-c++
            git
            make
            patch
            python3-colcon-common-extensions
            python3-flake8-builtins
            python3-flake8-comprehensions
            python3-flake8-import-order
            python3-flake8-quotes
            python3-mypy
            python3-pip
            python3-pydocstyle
            python3-pytest
            python3-pytest-repeat
            python3-pytest-rerunfailures
            python3-rosdep
            python3-setuptools
            python3-vcstool
            wget
        ]]
            -- python3-flake8-docstrings

        pip_install [[
            flake8-blind-except==0.1.1
            flake8-class-newline
            flake8-deprecated
        ]]

        run "sudo dnf install 'dnf-command(config-manager)' epel-release -y"
        run "sudo dnf config-manager --set-enabled crb"
        run "sudo curl --output /etc/yum.repos.d/ros2.repo http://packages.ros.org/ros2/rhel/ros2.repo"
        run "sudo dnf makecache"

        dnf_install "ros-iron-ros-base"
        --dnf_install "ros-iron-desktop"

    end

end
