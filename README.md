# chef-gitrob

Install and configure [Gitrob](https://github.com/michenriksen/gitrob)

## Supported Platforms

For now, Ubuntu 14.04 only is supported.

## Attributes

* default['gitrob']['version'] = '0.0.5'
* default['gitrob']['accept_agreement'] = nil
* default['gitrob']['pgsql_password'] = 'password'
* default['gitrob']['database'] = 'gitrob'
* default['gitrob']['database_user'] = 'gitrob'
* default['gitrob']['database_password'] = 'password'
* default['gitrob']['tokens'] = []
* default['gitrob']['organizations'] = []
* default['gitrob']['bind_address'] = '172.28.128.13'
* default['gitrob']['enable_check'] = false

## Usage

You need to set three attributes to make it works :

* default['gitrob']['accept_agreement'] = true
* default['gitrob']['tokens'] = ['TOKEN1', 'TOKEN2']
* default['gitrob']['organizations'] = ['organization1', 'organization2']

### gitrob::default

Include `gitrob` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gitrob::default]"
  ]
}
```

## License and Authors

```
Copyright 2015 Léonard TAVAE

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Authors :

* Léonard TAVAE (<leonard.tavae@informatique.gov.pf>)
