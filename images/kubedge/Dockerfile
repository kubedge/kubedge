# Copyright 2018 Kubedge.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM scratch
ADD kubedge/ca-certificates.crt /etc/ssl/certs/
ADD kubedge/webapp1 /webapp1
ADD kubedge/webapp2 /webapp2
ADD kubedge/goserv /goserv
EXPOSE 8080
CMD ["/goserv"]
