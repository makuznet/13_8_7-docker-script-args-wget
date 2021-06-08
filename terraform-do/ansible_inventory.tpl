---
all:
  hosts:
  children:
    web:
      hosts:
    %{for num in drop_num~}
      ${drop_dns[num]}:
            ansible_host: ${drop_ip[num]}
            ansible_user: ${drop_user}
    %{endfor~}
