title(...)

local move_docker_to_home = false
local ros = false

dnf_install "dnf-plugins-core"

dnf_install [[
    astyle
]]

-- AWS
if UPDATE then
    pip_install "awscli boto3"
    run { "sudo groupadd docker || true" }
    run { "sudo usermod -a -G docker", USER }
    run { "sudo systemctl enable docker || true" }
end

-- Docker
if UPDATE then
    -- https://docs.docker.com/engine/install/fedora/
    run "sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo --overwrite"
    dnf_install [[
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ]]
    run "sudo systemctl start docker || true"
end

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
    pyaml
    pydantic
    python-can
    scipy
    tftpy
    tqdm
]]

-- ROS: http://wiki.ros.org/Installation/Source
if ros then
    copr("/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:thofmann:ros.repo", "thofmann/ros")
    if tonumber(OS_RELEASE_VERSION_ID) <= 34 then
        dnf_install [[
            ros-desktop_full-devel
        ]]
    else
        dnf_install [[
            ros-ros_base
            ros-ros_base-devel
        ]]
    end
            --[=[ WARNING: this does not seem to work!
            dnf_install [[
                gcc-c++ python3-rosdep python3-rosinstall_generator python3-vcstool @buildsys-build
                python3-sip-devel qt-devel python3-qt5-devel
            ]]
            if not dir_exist "%(HOME)/ros_catkin_ws" then
                log "Build ROS"
                sh "sudo rosdep init"
                sh "rosdep update"
                sh [[
                    mkdir -p %(HOME)/ros_catkin_ws;
                    cd %(HOME)/ros_catkin_ws;
                    rosinstall_generator desktop --rosdistro noetic --deps --tar > noetic-desktop.rosinstall;
                    mkdir -p src;
                    vcs import --input noetic-desktop.rosinstall ./src;
                    rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y;
                    ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3;
                ]]
            end
            --]=]
end
